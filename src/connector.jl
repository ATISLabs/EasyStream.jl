using Tables
abstract type AbstractConnector end
Base.length(conn::AbstractConnector) = Inf
hasnext(conn::AbstractConnector) = true
reset!(conn::AbstractConnector) = nothing

abstract type LoopType end
struct Foward <: LoopType end
struct Backward <: LoopType end
struct Yoyo <: LoopType end
struct None <: LoopType end

mutable struct TablesConnector <: AbstractConnector
    rows
    state::Int
    args::Dict{Symbol, Any}
    loop::LoopType
    incremental::Int
end

function TablesConnector(data; shuffle::Bool = false, loop::LoopType = None())

    if !Tables.istable(data)
        throw(ArgumentError("data must have the Tables.jl interface"))
    end

    if shuffle
        data = data[Random.shuffle(1:size(data,1)), :]
    end
    state = typeof(loop) == typeof(Backward()) ? size(data, 1) + 1 : 0
    incremental = typeof(loop) == typeof(Backward()) ? -1 : 1
    return TablesConnector(Tables.rows(data), state, Dict{Symbol, Any}(),loop,incremental)
end



function TablesConnector(data, orderBy::Symbol; rev::Bool = false, loop::LoopType = None())
    if !(orderBy in propertynames(data))
        throw(ArgumentError("data doesn't have the column $orderBy"))
    end

    data = sort(data, orderBy, rev = rev)
    return TablesConnector(data;loop = loop)
end

TablesConnector(filename::String) = TablesConnector(CSV.read(filename; header = false))

Base.length(conn::TablesConnector) = length(conn.rows)
function hasnext(conn::TablesConnector)
    if typeof(conn.loop) == typeof(None())
        return conn.state < length(conn)
    else
        return true
    end
end

function next(conn::TablesConnector) return next(conn,conn.loop) end

function next(conn::TablesConnector,::None)
    if conn.state >= length(conn)
        return nothing
    end

    conn.state += 1
    return DataFrame([conn.rows[conn.state]])
end

function next(conn::TablesConnector,::Foward)
    conn.state += conn.incremental
    temp = conn.state % length(conn)
    conn.state = temp == 0 ? length(conn) : temp
    return DataFrame([conn.rows[conn.state]])
end

function next(conn::TablesConnector,::Backward)
    conn.state += conn.incremental
    temp = conn.state % length(conn)
    conn.state = temp == 0 ? length(conn) : temp
    return DataFrame([conn.rows[conn.state]])
end

function next(conn::TablesConnector,::Yoyo)
    conn.state += conn.incremental
    if conn.state == length(conn)
        conn.incremental *= - 1
    elseif conn.state == 0
        conn.state = 2
        conn.incremental *= - 1
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
