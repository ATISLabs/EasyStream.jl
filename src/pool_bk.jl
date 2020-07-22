mutable struct Pool{T <: Stream, N}
    stream::T
    data::Vector{N}
    mapping::Vector{Vector{Bool}}
    size::Int64
    N
end

function Pool(stream::Stream)
    data = Vector{DataFrame}()
    streamdata = next!(stream)
    push!(data, streamdata)
    mapping = Vector{Vector{Bool}}()
    push!(mapping, ones(Bool, size(streamdata, 1)))
    
    return Pool(stream, data, mapping, size(streamdata, 1), DataFrame)
end

function next!(pool::Pool)
    streamdata = next!(pool.stream)
    pool.size += size(streamdata, 1)
    
    #push!(pool.mapping, rand(Bool, size(streamdata, 1)))
    push!(pool.mapping, ones(Bool, size(streamdata, 1)))
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
function Base.getindex(pool::Pool, instance::Int)
    count = 1
    for i=1:size(pool.data, 1)
        for j=1:size(pool.data[i], 1)
            if pool.mapping[i][j]
                if count == instance
                    return pool.data[i][j, :]
                end
                count += 1 
            end
        end
    end
end

function Base.getindex(pool::Pool, i::Colon)
    data = pool.N()
    for i=1:useble_length(pool)
        push!(data, pool[i])
    end
    return data
end

function Base.getindex(pool::Pool, range::UnitRange{Int64})
    data = pool.N()
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


function Base.getindex(pool::Pool, instance::Colon, feature::Colon, sample::Int)
    count = 1
    data = pool.N()
    for j=1:size(pool.data[sample], 1)
        if pool.mapping[sample][j]
                push!(data, pool.data[sample][j, :])
            count += 1
        end
    end
    return data
end

function Base.getindex(pool::Pool, instance::Colon, feature::Colon, sample::UnitRange{Int64})
    count = 1
    data = pool.N()
    for i=range
        for j=1:size(pool.data[i], 1)
            if pool.mapping[i][j]
                if count == instance
                    push!(data, pool.data[i][j, :])
                end
                count += 1
            end
        end
    end
    return data
end

Base.getindex(pool::Pool, instance::Colon, feature::Colon, sample::Colon) = pool[:]

Base.getindex(pool::Pool, instance, feature, sample) = pool[:, :, sample][instance, feature]
