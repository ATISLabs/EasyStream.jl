mutable struct Stream
    samples
    initial_sample_size::Int64
    total_samples::Int64
    labels::Int64
    pointer::Int64
    fluxDensity::Int64
    endInstance::Bool

    function Stream()
        newStream = new()
        newStream.pointer = 0
        newStream.samples = []
        return newStream
    end
    
    function Stream(initial_sample_size, total_samples, fluxDensity)
        newStream = Stream()
        newStream.initial_sample_size = initial_sample_size
        newStream.total_samples = total_samples
        newStream.fluxDensity = fluxDensity
        return newStream
    end
end

function Stream(st::StreamFeeder)
    stream = Stream(st.initial_sample_size, st.total_samples, st.fluxDensity)
    push!(stream.samples, initialsample!(st))
    sample = next!(st)
    while sample != -1
        push!(stream.samples, sample)
        sample = next!(st)
    end
    return stream
end

function next(stream::Stream)
    stream.pointer += 1
end

## Until functions

function Base.length(stream::Stream)
    return size(stream.samples[stream.pointer + 1], 1)
end

function Base.lastindex(stream::Stream)
    return length(stream)
end

function Base.lastindex(stream::Stream, d::Int64)
    if(d==1)
        stream.endInstance = true
        return -1
    elseif(d==2)
        return length(stream[1])
    elseif(d==3)
        return length(stream.samples)
    end
end

### Exploring the three dimensions
function Base.getindex(stream::Stream, instance::Int64, feature::Int64, sample::Int64)
    if stream.endInstance == true && instance == -1
        instance = size(stream.samples[sample], 1)
        stream.endInstance == false
    end
    return stream.samples[sample][instance, feature]
end

function Base.getindex(stream::Stream, instance::Int64, c::Colon, sample::Int64)
    if stream.endInstance == true && instance == -1
        instance = size(stream.samples[sample], 1)
        stream.endInstance == false
    end
    return stream.samples[sample][instance, :]
end

function Base.getindex(stream::Stream, c::Colon, feature::Int64, sample::Int64)
    return stream.samples[sample][:, feature]
end

function Base.getindex(stream::Stream, c::Colon, c1::Colon, sample::Int64)
    return stream.samples[sample]
end

### Exploring two dimensions

function Base.getindex(stream::Stream, instance::Int64, feature::Int64)
    return stream[instance, feature, stream.pointer + 1]
end

function Base.getindex(stream::EasyStream.Stream, instance::Int64, c::Colon)
    return stream[instance, :, stream.pointer + 1]
end

### Exploring the one dimension

function Base.getindex(stream::Stream, instance::Int64)
    return stream[instance, :, stream.pointer + 1]
end

function Base.getindex(stream::Stream, c::Colon)
    return stream[:,:, stream.pointer + 1]
end
