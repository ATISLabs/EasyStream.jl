using Tables

abstract type AbstractConnector end

mutable struct TablesConnector <: AbstractConnector
    rows
    state::Int
end

TablesConnector(df::DataFrames.DataFrame) = TablesConnector(Tables.rows(df), 0)

TablesConnector(filename::String) = TablesConnector(CSV.read(filename; header = false))

function next(conn::AbstractConnector)
    if conn.state >= length(conn)
        return nothing
    end

    conn.state += 1

    return DataFrame(conn.rows[conn.state])
end

Base.length(conn::TablesConnector) = length(conn.rows)

hasnext(conn::TablesConnector) = conn.state < length(conn)