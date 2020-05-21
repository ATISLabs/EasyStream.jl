module EasyStream
    using MLJBase, MLJModels, Plots, StatsPlots, DataFrames, Suppressor
    import MLJ: @load, autotype
    import CSVFiles: load
    #import DataFrames: DataFrame, CategoricalArray, names!
    export @load, DataFrame, categorical, accuracy, coerce!, autotype, load, coerce


    fmeasures = Dict(
        :accuracy => accuracy,
        :time => nothing,
        :allocation => nothing
    )

    performance_measures = [:time, :allocation]
    format = (:stream, :model, :measure)


    mutable struct Stream
        name::String
        samples
        labels
        n_avaiable_labels::Int64

        function Stream(n_avaiable_labels, samples::Array{<:Number}, labels; name = nothing)
            new_stream = new()
            new_stream.name = name
            new_stream.labels = labels
            new_stream.samples = samples
            new_stream.n_avaiable_labels = n_avaiable_labels
            return new_stream
        end
    end

    mutable struct MeasureSet
        predicted_ys
        streams
        models
        measures
        calculated_measures
        names::Dict
        sizes::Dict
        steps::Int64
        function MeasureSet()
            new_measureSet = new()
            new_measureSet.predicted_ys = nothing
            return new_measureSet
        end
    end

    include("./util/util.jl")
    include("./modelInterface/modelApi.jl")
    include("./generators/prequential_plots.jl")
    include("./generators/graphGenerator.jl")
    include("./generators/tables.jl")
    include("./generators/bars.jl")
    include("./evaluate.jl")
    include("./generate.jl")
    include("./run.jl")
end # module
