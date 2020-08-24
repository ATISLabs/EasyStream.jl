abstract type AbstractStream end

function Base.iterate(stream::AbstractStream, state = 1)
    data = listen(stream)

    return isempty(data) ? nothing : (data, state+1)
end

function Base.push!(stream::AbstractStream, modifier::Modifier)
    push!(stream.modifiers, modifier)

    return nothing
end

function clear!(stream::AbstractStream)
    for i = 1:length(stream.modifiers)
        pop!(stream.modifiers)
    end

    return nothing
end

function reset!(stream::AbstractStream)
    clear!(stream)
    reset!(stream.connector)
    stream.events = 0

    return nothing
end

function increment(stream::AbstractStream)
    stream.events += 1 
    return nothing
end

mutable struct BatchStream <: AbstractStream
    connector::AbstractConnector
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

function listen(stream::BatchStream)::DataFrame
    if !hasnext(stream.connector)
        return DataFrame()
    end

    increment(stream)

    values = DataFrame[]

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

struct Range
    state::Int
    stream::AbstractStream
end

function Base.iterate(range::Range, state = 1)
    if state > range.state
        return nothing
    end

    data = listen(range.stream)

    return isempty(data) ? nothing : (data, state+1)
end

function range(value::Int, stream::AbstractStream)
    return Range(value, stream)
end
