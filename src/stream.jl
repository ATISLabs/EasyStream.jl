abstract type AbstractStream end

struct BatchStream <: AbstractStream
    connector::AbstractConnector
    batch::Int
end

function BatchStream(conn::AbstractConnector; batch::Int = 1)
    if batch == 0
        @warn "flux size é zero"
    end

    return Source(conn, batch)
end

function listen(source::BatchStream)::DataFrame
    if !hasnext(source.connector)
        return nothing
    end

    values = eltype(source.connector.rows)[]

    for i = 1:source.batch
        !hasnext(source.connector) ? break : nothing

        push!(values, next(source.connector))
    end

    return DataFrame(values)
end