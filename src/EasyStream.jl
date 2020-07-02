module EasyStream
    using DataFrames

    include("stream.jl")
    include("pool.jl")
    include("datasets.jl")

    using .DatasetsStreams
end # module
