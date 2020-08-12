module EasyStream

using CSV
using DataFrames

include("connector.jl")
include("stream.jl")

include("datasets.jl")

end # module

