module EasyStream
    using DataFrames

    include("buffer.jl")
    include("stream.jl")
    include("datastreams.jl")

    using .DataStreams
end # module
