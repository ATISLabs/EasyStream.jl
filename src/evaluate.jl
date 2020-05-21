"""
    evaluate(streams, models; measures = [:time])
    evaluate(streams, models, steps::Int64; measures = [:time])

The function `evaluate` performs the calculus of all measures that were passed as parameter for it and return a struct storing these information.

**Arguments**
* `streams` is the variable that stores the data streams
* `models` is the variable that stores the models
* `measures` is the variable that stores the measures
* `steps` detemines wether the evaluate process will be diveded over parts

The streams, models and measures can be a only element or a vector of your respects elements.
"""
function evaluate(streams, models; measures = [:time], steps = 1)
    measureset = MeasureSet()

    n_models = 1
    n_streams = 1
    n_measures = 1

    ## Transforming single inputs into interative elements
    if models isa Array
        n_models = length(models)
    else
        models = [models]
    end

    if streams isa Array
        n_streams = length(streams)
    else
        streams = [streams]
    end

    if measures isa Array
        n_measures = length(measures)
    else
        measures = [measures]
    end

    ### Defining names of models and streams
    model_names = [string(typeof(m)) for m in models]
    model_names = [split(na, ".")[end] for na in model_names]

    for i in 1:length(model_names)
        k = 2
        for j in 1:length(model_names)
            if i == j
                continue
            end
            if model_names[i] == model_names[j]
                model_names[j] = model_names[j]*string(k)
                k += 1
            end

        end
    end

    stream_names = [streams[i].name != nothing ? streams[i].name : "ST$i" for i in 1:n_streams]

    ### Assigning the variables to the measureset
    used_measures = Set()
    for measure in measures
        push!(used_measures, measure)
    end
    for measure in performance_measures
        push!(used_measures, measure)
    end

    measureset.measures = used_measures
    measureset.streams = streams
    measureset.models = models
    measureset.steps = steps

    measureset.names = Dict(
        :model => model_names,
        :stream => stream_names)

    measureset.sizes = Dict(
    :model => n_models,
    :stream => n_streams)

    if steps == 1
        measure_calculate(measureset, measureset.measures)
    elseif steps > 1
        measure_calculate(measureset, measureset.measures, steps)
    end

    return measureset
end

function measure_calculate(measureset, measures)
    measures = copy(measures)

    if measures isa Set
        for measure in performance_measures
            delete!(measures, measure)
        end
        measures = collect(measures)
    end

    if measureset.predicted_ys == nothing
        measureset.calculated_measures = [[] for i in 1:measureset.sizes[:stream]]
        measureset.predicted_ys = [[] for i in 1:measureset.sizes[:stream]]
        performance_info = nothing
        for (i, stream) in enumerate(measureset.streams)
            ### Classification
            for model in measureset.models
                #amount = 1 + stream.n_avaiable_labels
                if model isa Deterministic
                    performance_info = @timed push!(measureset.predicted_ys[i], runS(stream, model))
                elseif model isa MLJBase.Deterministic
                    performance_info = @timed push!(measureset.predicted_ys[i], runMD(stream, model))
                elseif model isa MLJBase.Probabilistic
                    performance_info = @timed push!(measureset.predicted_ys[i], runMP(stream, model))
                end

                calculated_measure = Dict(
                    :time => performance_info[2],
                    :allocation => performance_info[3]
                )

                push!(measureset.calculated_measures[i], calculated_measure)
            end
        end
    end
    ### Calculating measures that will be used
    for measure in measures
        for (i, stream) in enumerate(measureset.streams)
            for j = 1:measureset.sizes[:model]
                measureset.calculated_measures[i][j][measure] = fmeasures[measure](measureset.predicted_ys[i][j], stream.labels[stream.n_avaiable_labels + 1:end])
            end
        end
    end

end

function measure_calculate(measureset, measures, steps)
    measures = copy(measures)

    for measure in performance_measures
        delete!(used_measures, measure)
    end

    ### Creating variables to save the measures
    measureset.calculated_measures = [[] for i in 1:measureset.sizes[:stream]]
    measureset.predicted_ys = [[] for i in 1:measureset.sizes[:stream]]
    performance_info = nothing
    for (i, stream) in enumerate(measureset.streams)
        ### Creating the interval based on number of steps to make the analisys in batchs of classifications
        prequential_interval = interval(length(stream.labels) - stream.n_avaiable_labels, steps)
        ### Classification
        for (k, model) in enumerate(measureset.models)
            _start = stream.n_avaiable_labels
            push!(measureset.predicted_ys[i], [])
            push!(measureset.calculated_measures[i], [])

            for j in 1:length(prequential_interval)
                _end = _start + prequential_interval[j]
                _start += 1
                if model isa Deterministic
                    performance_info = @timed push!(measureset.predicted_ys[i][k], runS(stream, model, [_start, _end]))
                elseif model isa MLJBase.Deterministic
                    performance_info = @timed push!(measureset.predicted_ys[i][k], runMD(stream, model, [_start, _end]))
                elseif model isa MLJBase.Probabilistic
                    performance_info = @timed push!(measureset.predicted_ys[i][k], runMP(stream, model, [_start, _end]))
                end
                calculated_measure = Dict(
                    :time => performance_info[2],
                    :allocation => performance_info[3]
                )
                push!(measureset.calculated_measures[i][k], calculated_measure)
                ### Calculating measures other measures
                for measure in measures
                    measureset.calculated_measures[i][k][j][measure] = fmeasures[measure](measureset.predicted_ys[i][k][j], stream.labels[_start:_end])
                end
                _start = _end
            end
        end
    end
end
