module EasyStream

using CSV
using DataFrames

include("connector.jl")
include("modifiers.jl")

include("stream.jl")

include("datasets.jl")

end # module

