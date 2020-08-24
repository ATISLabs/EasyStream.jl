using Tables

abstract type AbstractConnector end

mutable struct TablesConnector <: AbstractConnector
    rows
    state::Int
end

function next(conn::AbstractConnector)
    if conn.state >= length(conn)
        return nothing
    end

    conn.state += 1

    return DataFrame([conn.rows[conn.state]])
end

Base.length(conn::TablesConnector) = length(conn.rows)

hasnext(conn::TablesConnector) = conn.state < length(conn)

function TablesConnector(data)
    if !Tables.istable(data)
        @error "The dataset must have the Tables.jl interface"
    end

    return TablesConnector(Tables.rows(data), 0)
end

function TablesConnector(data, shuffle::Bool)
    if shuffle
        data = data[Random.shuffle(1:size(data,1)), :]
    end

    return TablesConnector(data)
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

reset!(conn::TablesConnector) = conn.state = 0