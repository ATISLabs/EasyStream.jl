using Tables

abstract type AbstractConnector end

Base.length(conn::AbstractConnector) = Inf
hasnext(conn::AbstractConnector) = true
reset!(conn::AbstractConnector) = nothing

mutable struct TablesConnector <: AbstractConnector
    rows
    state::Int
    args::Dict{String, Any}
end

function TablesConnector(data; shuffle::Bool = false)
    if !Tables.istable(data)
        @error "The dataset must have the Tables.jl interface"
    end

    if shuffle
        data = data[Random.shuffle(1:size(data,1)), :]
    end

    return TablesConnector(Tables.rows(data), 0, Dict{String, Any}())
end

function TablesConnector(data, orderBy::Symbol; rev::Bool = false)
    if orderBy in propertynames(data)
         data = sort(data, orderBy, rev = rev)
    else 
        @warn "The dataset doesn't have the column $orderBy"
    end

    return TablesConnector(data)
end

TablesConnector(filename::String) = TablesConnector(CSV.read(filename; header = false))

Base.length(conn::TablesConnector) = length(conn.rows)
hasnext(conn::TablesConnector) = conn.state < length(conn)

function next(conn::TablesConnector)
    if conn.state >= length(conn)
        return nothing
    end

    conn.state += 1

    return DataFrame([conn.rows[conn.state]])
end

reset!(conn::TablesConnector) = conn.state = 0

mutable struct GeneratorConnector <: AbstractConnector
    generator::Function
    args::Dict{Symbol, Any}
end

function GeneratorConnector(generator::Function;
                            args...)
    return GeneratorConnector(generator, args)
end

function next(conn::GeneratorConnector)
    total = 100
    data = conn.generator(;n_samples = total, conn.args...)
    
    return DataFrame(data[1 + Int(floor(rand(1,1)[1] .* size(data)[1])), :])
end
