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
Base.getindex(stream::Stream, sample::Int64) = stream.data[length(stream.data)][sample, :]

function next!(stream::Stream)
    push!(stream.data, next!(stream.buffer))
end
