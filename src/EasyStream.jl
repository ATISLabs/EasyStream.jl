using Revise
module EasyStream
    using CSVFiles, DataFrames

    include("./datatypes/StreamFeeder.jl")
    include("./datatypes/Stream.jl")
end # module
