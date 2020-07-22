module EasyStream
    using DataFrames

    include("source.jl")
    include("stream.jl")
    include("pool.jl")
    include("datasets.jl")

    using .DatasetsStreams
end # module
