module EasyStream

using CSV
using DataFrames

include("connector.jl")
include("modifiers.jl")

include("stream.jl")

include("datasets.jl")

export clear!, reset!

end # module
