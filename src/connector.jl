using Tables, StatsBase

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

function TablesConnector(df::DataFrames.DataFrame;
    orderBy = nothing,
    rev = false, 
    shuffle = false)  

    shuffle == true ? df = df[StatsBase.shuffle(1:size(df,1)), :] : orderBy != nothing && sort!(df, DataFrames.order(orderBy, rev=rev))

    return TablesConnector{DataFrame}(Tables.rows(df), 0)
end

TablesConnector(filename::String) = TablesConnector{DataFrame}(CSV.read(filename; header = false))