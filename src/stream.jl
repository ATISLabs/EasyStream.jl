struct Stream
    buffer::Buffer
    data::Vector{DataFrame}
end

function Stream(buffer::Buffer)
    data = Vector{DataFrame}()
    push!(data, next!(buffer))

    return Stream(buffer, data)
end

#TODO: Casos limites?
function Base.getindex(stream::Stream, instance::Int64)
    if instance > 0 && instance <= size(stream.data[length(stream.data)], 1)
        return stream.data[length(stream.data)][instance, :]
    else 
        throw(BoundsError(stream.data, instance))
    end
end

function Base.getindex(stream::Stream, c::Colon)
    return stream.data[length(stream.data)][:, :]
end

function Base.getindex(stream::Stream, index::UnitRange{Int})
    sample = DataFrame()
    for i=1:length(index)
        push!(sample, stream[index[i]])
    end
    return sample
end

function next!(stream::Stream)
    push!(stream.data, next!(stream.buffer))
end
