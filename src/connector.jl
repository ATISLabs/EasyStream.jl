using Tables
abstract type AbstractConnector end
Base.length(conn::AbstractConnector) = Inf
hasnext(conn::AbstractConnector) = true
reset!(conn::AbstractConnector) = nothing

mutable struct TablesConnector <: AbstractConnector
    rows
    state::Int
    args::Dict{Symbol, Any}
    loop::Symbol
    incremental::Int
end

function TablesConnector(data; shuffle::Bool = false, loop::Symbol = :none)

    if !Tables.istable(data)
        throw(ArgumentError("data must have the Tables.jl interface"))
    end
    loopTypes =[:none,:foward,:backward,:yoyo]
    if !(loop in loopTypes)
        throw(ArgumentError("Symbol $loop is not valid"))
    end

    if shuffle
        data = data[Random.shuffle(1:size(data,1)), :]
    end
    state = loop == :backward ? size(data, 1) + 1 : 0
    incremental = loop == :backward ? -1 : 1
    return TablesConnector(Tables.rows(data), state, Dict{Symbol, Any}(),loop,incremental)
end



function TablesConnector(data, orderBy::Symbol; rev::Bool = false, loop::Symbol = :none)
    if !(orderBy in propertynames(data))
        throw(ArgumentError("data doesn't have the column $orderBy"))
    end
    loopTypes =[:none,:foward,:backward,:yoyo]
    if !(loop in loopTypes)
        throw(ArgumentError("Symbol $loop is not valid"))
    end
    state = loop == :backward ? size(data, 1) + 1 : 0
    data = sort(data, orderBy, rev = rev)
    return TablesConnector(data;loop = loop)
end

TablesConnector(filename::String) = TablesConnector(CSV.read(filename; header = false))

Base.length(conn::TablesConnector) = length(conn.rows)
function hasnext(conn::TablesConnector)
    if conn.loop == :none
        return conn.state < length(conn)
    elseif conn.loop == :foward || conn.loop == :backward ||conn.loop == :yoyo
        return true
    end
end

function next(conn::TablesConnector)
    if conn.loop == :none
        if conn.state >= length(conn)
            return nothing
        end

        conn.state += 1
    elseif conn.loop == :foward || conn.loop == :backward
        conn.state += conn.incremental
        temp = conn.state % length(conn)
        conn.state = temp == 0 ? length(conn) : temp
    elseif conn.loop == :yoyo
        conn.state += conn.incremental
        if conn.state == length(conn)
            conn.incremental *= - 1
        elseif conn.state == 0
            conn.state = 2
            conn.incremental *= - 1
        end


    end
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
