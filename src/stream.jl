abstract type AbstractStream{T} end

function Base.iterate(stream::AbstractStream, state = 1)
    data = listen(stream)

    return isempty(data) ? nothing : (data, state+1)
end

function Base.push!(stream::AbstractStream, modifier::Modifier)
    push!(stream.modifiers, modifier)
    return nothing
end

function increment(stream::AbstractStream)
    stream.events += 1 
    return nothing
end

mutable struct BatchStream{T} <: AbstractStream{T}
    connector::AbstractConnector{T}
    batch::Int
    modifiers::Array{Modifier}
    events::Int
end

function BatchStream(conn::AbstractConnector; batch::Int = 1)
    if batch == 0
        @warn "flux size é zero"
    end

    return BatchStream(conn, batch, Modifier[], 0)
end

function listen(stream::BatchStream{T})::T where T
    if !hasnext(stream.connector)
        return T()
    end

    increment(stream)

    values = T[]

    for i = 1:stream.batch
        !hasnext(stream.connector) ? break : nothing

        data = next(stream.connector)
        for modifier in stream.modifiers
            apply!(modifier, data, stream.events)
        end
        
        push!(values, data)
    end

    return vcat(values...)
end