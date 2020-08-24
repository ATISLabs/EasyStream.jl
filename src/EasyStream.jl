module EasyStream

using CSV
using DataFrames

include("connector.jl")
include("modifiers.jl")

include("stream.jl")

include("others.jl")

include("datasets.jl")

include("drifts.jl")

export clear!, reset!

end # module
