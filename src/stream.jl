abstract type AbstractStream end

function Base.push!(stream::AbstractStream, modifier::Modifier)
    push!(stream.modifiers, modifier)
    return nothing
end

struct BatchStream <: AbstractStream
    connector::AbstractConnector
    batch::Int
    modifiers::Array{Modifier}
end

function BatchStream(conn::AbstractConnector; batch::Int = 1)
    if batch == 0
        @warn "flux size é zero"
    end

    return BatchStream(conn, batch, Modifier[])
end

function listen(stream::BatchStream)::DataFrame
    if !hasnext(stream.connector)
        return nothing
    end

    values = DataFrame[]

    for i = 1:stream.batch
        !hasnext(stream.connector) ? break : nothing

        data = next(stream.connector)
        for modifier in stream.modifiers
            apply!(modifier, data)
        end
        
        push!(values, data)
    end

    return vcat(values...)
end