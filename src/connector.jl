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
        @error "the data must be of type Tables"
    end

    return TablesConnector(Tables.rows(data), 0)
end

function TablesConnector(data, shuffle::Bool)

    shuffle == true ? data = data[Random.shuffle(1:size(data,1)), :] : nothing

    return TablesConnector(data)
end

function TablesConnector(data, orderBy::Symbol; rev::Bool = false)

    orderBy != :default && (orderBy in propertynames(data) ? data = sort(data, orderBy, rev = rev) : @warn "A tabela não possui a coluna $orderBy")

    return TablesConnector(data)
end

TablesConnector(filename::String) = TablesConnector(CSV.read(filename; header = false))

reset!(conn::TablesConnector) = conn.state = 0