function increment(event::Event)
    event.time += 1
    nothing
end

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

increment(stream::AbstractStream) = increment(stream.event)

mutable struct BatchStream <: AbstractStream
    connector::AbstractConnector
    batch::Int
    modifiers::Array{Modifier}
    event::Event
end

function BatchStream(conn::AbstractConnector; batch::Int = 1)
    if batch <= 0
        throw(ArgumentError("batch must be greater than 0"))
    end

    return BatchStream(conn, batch, Modifier[], Event(conn.args))
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
            apply!(modifier, data, stream.event)
        end
        
        push!(values, data)
    end

    return vcat(values...)
end
