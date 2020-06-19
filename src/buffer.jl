using CSV

abstract type Buffer end

mutable struct MemoryBuffer <: Buffer
    data::DataFrame
    position::Int
    initial_size::Int
    flux_size::Int
end

function MemoryBuffer(path::String, initial_size::Int, flux_size::Int)
    data = CSV.read(path; header = false)

    if(initial_size > size(data, 1))
        initial_size = size(data, 1)
        @warn "initial size é maior que o arquivo e será definido para o tamanho do arquivo"
    end

    if initial_size == 0
        @warn "initial size é zero"
    end

    if flux_size == 0
        @warn "flux size é zero"
    end

    return MemoryBuffer(data, 0, initial_size, flux_size)
end

Dataset1CDT() = Dataset1CDT(150, 1)
Dataset1CDT(initial_size::Int, flux_size::Int) = MemoryBuffer("datasets/1CDT.csv", initial_size, flux_size)

next!(buffer::Buffer) = nothing

function next!(buffer::MemoryBuffer)
    if(buffer.position >= size(buffer.data, 1))
        return nothing
    end

    if(buffer.position < buffer.initial_size)
        buffer.position = buffer.initial_size
        return buffer.data[1:buffer.initial_size, :]
    else
        index = (buffer.position + 1):(buffer.position + buffer.flux_size)
        buffer.position = buffer.position + buffer.flux_size
        return buffer.data[index, :]
    end
end
