struct Pool{T <: Stream}
    stream::T
    data::Vector{DataFrame}
    mapping::Vector{Vector{Bool}}
end

function Pool(stream::Stream)
    data = Vector{DataFrame}()
    push!(data, next!(stream))

    mapping = Vector{Vector{Bool}}()
    push!(mapping, ones(Bool, size(data, 1)))
    return Pool(stream, data, mapping)
end

function next!(pool::Pool)
    streamdata = next!(pool.buffer)
    push!(pool.data, streamdata)

    push!(pool.mapping, rand(Bool, size(streamdata, 1)))
end

function Base.getindex(pool::Pool, i::Int)
    return pool.data[1][1, :]
end

Base.getindex(pool::Pool, i::Int, j::Int) = pool[i][j]
