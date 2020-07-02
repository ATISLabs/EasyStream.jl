module EasyStream
    using DataFrames

    include("buffer.jl")
    include("datasets.jl")
    include("datastream.jl")

    using .DatasetsStreams
end # module
