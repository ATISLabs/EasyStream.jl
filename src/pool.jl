mutable struct Pool{T <: Stream}
    stream::T
    data::Vector{DataFrame}
    mapping::Vector{Vector{Bool}}
    size::Int64
end

function Pool(stream::Stream)
    data = Vector{DataFrame}()
    streamdata = next!(stream)
    push!(data, streamdata)
    mapping = Vector{Vector{Bool}}()
    push!(mapping, ones(Bool, size(streamdata, 1)))
    
    return Pool(stream, data, mapping, size(streamdata, 1))
end

function next!(pool::Pool)
    streamdata = next!(pool.stream)
    pool.size += size(streamdata, 1)
    
    push!(pool.mapping, rand(Bool, size(streamdata, 1)))
    push!(pool.data, streamdata)
    return streamdata
end


##Utils 
function useble_length(pool)
    count = 0
    for i=1:size(pool.data, 1)
        for j=1:size(pool.data[i], 1)
            if pool.mapping[i][j]
                count += 1 
            end
        end
    end
    return count
end

##Indexing - Using three indexes to move in data through the instances
function Base.getindex(pool::Pool, index::Int)
    count = 1
    for i=1:size(pool.data, 1)
        for j=1:size(pool.data[i], 1)
            if pool.mapping[i][j]
                if count == index
                    return pool.data[i][j, :]
                end
                count += 1 
            end
        end
    end
end

function Base.getindex(pool::Pool, i::Colon)
    data = DataFrame()
    for i=1:useble_length(pool)
        push!(data, pool[i])
    end
    #=
    data = DataFrame()
    for i=1:size(pool.data, 1)
        for j=1:size(pool.data[i], 1)
            if pool.mapping[i][j]
                push!(data, pool.data[i][j, :])
            end
        end
    end
    =#
    return data
end

function Base.getindex(pool::Pool, range::UnitRange{Int64})
    data = DataFrame()
    for i in range
        push!(data, pool[i])
    end
    return data
end

##Indexing - Using two indexes to move in data through the instances and features

Base.getindex(pool::Pool, instance::Int, feature::Int) = pool[instance][feature]

Base.getindex(pool::Pool, instance::Int, c::Colon) = pool[instance]

Base.getindex(pool::Pool, instance::Int, range::UnitRange{Int64}) = pool[instance][range] 

Base.getindex(pool::Pool, c::Colon, feature::Int) = pool[:][:, feature]

Base.getindex(pool::Pool, c::Colon, range::UnitRange{Int64}) = pool[:][:, range]

Base.getindex(pool::Pool, c1::Colon, c2::Colon) = pool[:]

Base.getindex(pool::Pool, range::UnitRange{Int64}, feature::Int) = pool[range][:, feature]

Base.getindex(pool::Pool, range::UnitRange{Int64}, c::Colon) = pool[range]

Base.getindex(pool::Pool, range::UnitRange{Int64}, range2::UnitRange{Int64}) = pool[range][:, range2]

##Indexing - Using three indexes to move in data through the instances, features, samples


