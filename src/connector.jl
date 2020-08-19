using Tables, Random

abstract type AbstractConnector{T} end

mutable struct TablesConnector{T} <: AbstractConnector{T}
    rows
    state::Int
end

function next(conn::AbstractConnector{T})::T where T
    if conn.state >= length(conn)
        return nothing
    end

    conn.state += 1

    return T(conn.rows[conn.state])
end

Base.length(conn::TablesConnector) = length(conn.rows)

hasnext(conn::TablesConnector) = conn.state < length(conn)

function TablesConnector(df::T;
    orderBy = nothing,
    rev = false, 
    shuffle = false) where {T}

    shuffle == true ? df = df[Random.shuffle(1:size(df,1)), :] : orderBy != nothing && sort!(df, orderBy, rev = rev)

    return TablesConnector{T}(Tables.rows(df), 0)
end

TablesConnector(filename::String) = TablesConnector{DataFrame}(CSV.read(filename; header = false))