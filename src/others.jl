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
