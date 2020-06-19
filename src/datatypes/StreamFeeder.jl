abstract type StreamFeeder end

mutable struct FileStream <: StreamFeeder
    initial_sample_size::Int64
    total_samples::Int64
    labels::Int64
    delimiter::String
    ioStream
    pointer::Int64
    fluxDensity::Int64

    function FileStream()
        return new()
    end
end

function FileStream(path::String; header = false, initial_sample_size = 150, fluxDensity = 1, delimiter = ",")
    fileStream = FileStream()
    fileStream.initial_sample_size = initial_sample_size
    fileStream.pointer = 0
    fileStream.ioStream = open(path)
    fileStream.delimiter = delimiter
    fileStream.fluxDensity = fluxDensity
    fileStream.total_samples = size(fileStream.samples, 1)

    return fileStream
end

function readStream(stream::FileStream)
    instance = split(readline(stream.ioStream), stream.delimiter)
    if instance == [""]
        return -1
    end
    instance = convert(Array{Any, 1}, instance)
    for i = 1:length(instance)
        if '.' in instance[i]
            x = tryparse(Float64, instance[i])
            if x != nothing
                instance[i] = x
            else
                instance[i] = instance[i]
            end
        else
            x = tryparse(Int64, instance[i])
            if x != nothing
                instance[i] = x
            else
                instance[i] = instance[i]
            end
        end
    end
    return permutedims(instance)
end

function next(stream::StreamFeeder)
    old_position = position(stream.ioStream)
    instance = readStream(stream)
    seek(stream.ioStream, old_position)
    return instance
    #=
    if stream.pointer == stream.total_samples
        return -1
    end
    sample = stream.samples[stream.pointer + 1:stream.pointer + stream.fluxDensity, :]
    return sample
    =#

end

function next!(stream::StreamFeeder)
    return readStream(stream)
    #=
    if stream.pointer == stream.total_samples
        return -1
    end
    sample = stream.samples[stream.pointer + 1:stream.pointer + stream.fluxDensity, :]
    stream.pointer += stream.fluxDensity
    return sample
    =#
end

function rewind(stream::StreamFeeder)
    seekstart(stream.ioStream)
end

function initialsample(stream::StreamFeeder)
    old_position = position(stream.ioStream)
    rewind(stream)
    sample = next!(stream)
    for _ in 2:stream.initial_sample_size
        sample = vcat(sample, next!(stream))
    end
    seek(stream.ioStream, old_position)
    return sample
end

function initialsample!(stream::StreamFeeder)
    rewind(stream)
    sample = next!(stream)
    for _ in 1:stream.initial_sample_size
        sample = vcat(sample, next!(stream))
    end
    return sample
    #=
    stream.pointer = stream.initial_sample_size
    return stream.samples[1:stream.initial_sample_size, :]
    =#
end
