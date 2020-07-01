struct Stream
    buffer::Buffer
    data::Vector{DataFrame}
end

function Stream(buffer::Buffer)
    data = Vector{DataFrame}()
    push!(data, next!(buffer))
    return Stream(buffer, data)
end

#Using one index to explore the data
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

#Using two index to explore the data
function Base.getindex(stream::Stream, instance::Int64, feature::Int64)
    if feature > 0 && feature <= size(stream[instance], 1)
        return stream[instance][feature]
    else 
        throw(BoundsError(stream.data, feature))
    end
end

function Base.getindex(stream::Stream, c::Colon, feature::Int64)
    if feature > 0 && feature <= size(stream[:], 2)
        return stream[:][:, feature]
    else 
        throw(BoundsError(stream.data, feature))
    end
end

function Base.getindex(stream::Stream, index::UnitRange{Int}, feature::Int64)
    if feature > 0 && feature <= size(stream[:], 2)
        return stream[index][:, feature]
    else 
        throw(BoundsError(stream.data, feature))
    end
end

function Base.getindex(stream::Stream, index::UnitRange{Int}, c::Colon)
    return stream[index]
end

function Base.getindex(stream::Stream, instance::Int64, c::Colon)
    return stream[instance]
end

function Base.getindex(stream::Stream, c::Colon, c2::Colon)
    return stream[:]
end

function Base.getindex(stream::Stream, instance::Int64, index::UnitRange{Int})
    return [stream[instance, index[i]] for i = 1:length(index)]
end

function Base.getindex(stream::Stream, c::Colon, index::UnitRange{Int})
    sample = DataFrame()
    for i = 1:size(stream[:], 1)
        append!(sample, DataFrame(permutedims(stream[i, index])))
    end
    return sample
end

function Base.getindex(stream::Stream, indexI::UnitRange{Int}, indexF::UnitRange{Int})
    sample = DataFrame()
    for i = 1:length(indexI)
        append!(sample, DataFrame(permutedims(stream[indexI[i], indexF])))
    end
    return sample
end

function next!(stream::Stream)
    push!(stream.data, next!(stream.buffer))
end
