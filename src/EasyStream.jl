using MLJBase, Plots, StatsPlots, DataFrames
import MLJModels: fit, predict, predict_mode
import MLJ: @load, autotype
#import DataFrames: DataFrame, CategoricalArray, names!
export @load, DataFrame, categorical, accuracy, coerce!, autotype

mutable struct Stream
    name::String
    window_size::Int64
    stream_type
    samples
    labels
    n_avaiable_labels
    function Stream(window_size, n_avaiable_labels, samples::Array{<:Number}, labels; name = nothing)
        new_stream = new()
        new_stream.name = name
        new_stream.labels = labels
        new_stream.samples = samples
        new_stream.window_size = window_size
        new_stream.n_avaiable_labels = n_avaiable_labels
        return new_stream
    end
end

include("./util/util.jl")
include("./modelInterface/modelApi.jl")
include("./graphGenerator/graphGenerator.jl")
include("./evaluate.jl")
include("./evaluateT.jl")
include("./run.jl")

end # module
