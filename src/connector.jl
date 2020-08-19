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

function TablesConnector(df::T;
    orderBy::Symbol = :default,
    rev::Bool = false, 
    shuffle::Bool = false) where {T}

    shuffle == true ? df = df[Random.shuffle(1:size(df,1)), :] : nothing
    orderBy != :default && orderBy in propertynames(df) ? df = sort(df, orderBy, rev = rev) : @warn "A tabela não possui a coluna $orderBy" 

    return TablesConnector{T}(Tables.rows(df), 0)
end

TablesConnector(filename::String) = TablesConnector{DataFrame}(CSV.read(filename; header = false))