abstract type Stream end

mutable struct MemoryStream{T} <: Stream{T}
    data::T
    position::Int
    initial_size::Int
    batch::Int
end

function MemoryStream(data::T, initial_size::Int, batch::Int)
    if initial_size > size(data, 1)
        initial_size = size(data, 1)
        @warn "initial size é maior que o arquivo e será definido para o tamanho do arquivo"
    end

    if initial_size == 0
        @warn "initial size é zero"
    end

    if batch == 0
        @warn "flux size é zero"
    end

    return MemoryStream(data, 0, initial_size, batch)
end

next!(buffer::Stream) = nothing

function next!(stream::MemoryStream)
    if stream.position >= size(stream.data, 1)
        return nothing
    end

    if stream.position < stream.initial_size
        stream.position = stream.initial_size
        index = 1:stream.initial_size
    else
        index = (stream.position + 1):(stream.position + stream.batch)
        stream.position = stream.position + stream.batch
    end

    return stream.data[index, :]
end
