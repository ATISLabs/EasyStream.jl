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
    if instance <= size(stream.data[length(stream.data)], 1)
        return stream.data[length(stream.data)][instance, :]
    else 
        throw("attempt to access a sample with $(size(stream.data[length(stream.data)], 1)) elements at index [$instance]")
    end
end

function Base.getindex(stream::Stream, c::Colon)
    return stream.data[length(stream.data)][:, :]
end

function next!(stream::Stream)
    push!(stream.data, next!(stream.buffer))
end
