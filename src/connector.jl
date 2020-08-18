using Tables

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

TablesConnector(df::DataFrames.DataFrame) = TablesConnector{DataFrame}(Tables.rows(df), 0)

TablesConnector(filename::String) = TablesConnector{DataFrame}(CSV.read(filename; header = false))