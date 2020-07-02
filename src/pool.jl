struct Pool{T <: Stream}
    stream::T
    data::Vector{DataFrame}
end

function Pool(stream::Stream)
    data = Vector{DataFrame}()
    push!(data, next!(stream))
    return Pool(stream, data)
end

function next!(pool::Pool)
    push!(pool.data, next!(pool.buffer))
end

#Using one index to explore the data
function Base.getindex(pool::Pool, instance::Int64)
    if instance > 0 && instance <= size(pool.data[length(pool.data)], 1)
        return pool.data[length(pool.data)][instance, :]
    else
        throw(BoundsError(pool.data, instance))
    end
end

function Base.getindex(pool::Pool, c::Colon)
    return pool.data[length(pool.data)][:, :]
end

function Base.getindex(pool::Pool, index::UnitRange{Int})
    sample = DataFrame()
    for i=1:length(index)
        push!(sample, pool[index[i]])
    end
    return sample
end

#Using two index to explore the data
function Base.getindex(pool::Pool, instance::Int64, feature::Int64)
    if feature > 0 && feature <= size(pool[instance], 1)
        return pool[instance][feature]
    else
        throw(BoundsError(pool.data, feature))
    end
end

function Base.getindex(pool::Pool, c::Colon, feature::Int64)
    if feature > 0 && feature <= size(pool[:], 2)
        return pool[:][:, feature]
    else
        throw(BoundsError(pool.data, feature))
    end
end

function Base.getindex(pool::Pool, index::UnitRange{Int}, feature::Int64)
    if feature > 0 && feature <= size(pool[:], 2)
        return pool[index][:, feature]
    else
        throw(BoundsError(pool.data, feature))
    end
end

function Base.getindex(pool::Pool, index::UnitRange{Int}, c::Colon)
    return pool[index]
end

function Base.getindex(pool::Pool, instance::Int64, c::Colon)
    return pool[instance]
end

function Base.getindex(pool::Pool, c::Colon, c2::Colon)
    return pool[:]
end

function Base.getindex(pool::Pool, instance::Int64, index::UnitRange{Int})
    return [pool[instance, index[i]] for i = 1:length(index)]
end

function Base.getindex(pool::Pool, c::Colon, index::UnitRange{Int})
    sample = DataFrame()
    for i = 1:size(pool[:], 1)
        append!(sample, DataFrame(permutedims(pool[i, index])))
    end
    return sample
end

function Base.getindex(pool::Pool, indexI::UnitRange{Int}, indexF::UnitRange{Int})
    sample = DataFrame()
    for i = 1:length(indexI)
        append!(sample, DataFrame(permutedims(pool[indexI[i], indexF])))
    end
    return sample
end
