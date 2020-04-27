function evaluate(streams, models; measures = accuracy, output = :table, header = nothing, steps::Int64 = 10)

    n_models = 1
    n_streams = 1
    n_measures = 1

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

    if output isa Array
    else
        output = [output]
    end


    ###r_output structure
    r_output = (tables=[DataFrame() for measure in measures], graphs=Array{Any, 1}(),  bars=Array{Any, 1}())

    ###model names
    if header == nothing
        model_names = [string(typeof(m)) for m in models]
        model_names = [split(na, ".")[end] for na in model_names]
    elseif length(header) == n_models
        model_names = header
    else
        error("length(header) is different than length(models) ")
    end

    stream_names = [streams[i].name != nothing ? streams[i].name : "ST$i" for i in 1:n_streams]


    for (i, stream) in enumerate(streams)

        ### Creating the interval to do the analisys using the number of steps
        prequential_interval = interval(length(stream.labels) - stream.n_avaiable_labels, steps)
        ###

        predicted_ys = [Array{Any, 1}() for i in 1:n_models]

        ###Classification
        for (k, model) in enumerate(models)
            amount = 1 + stream.n_avaiable_labels

            ###Model initialization
            fitresult, _, _ = MLJModels.fit(model, 0, stream.samples[1:stream.n_avaiable_labels, :], stream.labels[1:stream.n_avaiable_labels, :])

            ###Creating the needed data to distributionByClass function
            if :prequetialDis in output
                pred(x, y) = convert(Int64, DMClassification.onlyfit(model, fitresult, [x, y]))
                xg = range(minimum(stream.samples[:,1]), maximum(stream.samples[:,1]), length=50)
                yg = range(minimum(stream.samples[:,2]), maximum(stream.samples[:,2]), length=50)
            end

            ###Classifying the samples and gerating graphs using distributionByClass if it was set as a output
            for j in 1:steps
                next_amount = (amount - 1) + prequential_interval[j]
                X = stream.samples[amount:next_amount, :]

                predicted_y = MLJModels.predict(model, fitresult, stream.samples[amount:next_amount,:])

                if :prequetialDis in output
                    push!(r_output.graphs, distributionByClass(xg, yg, X, pred, predicted_y))
                end

                append!(predicted_ys[k], predicted_y)
                amount = next_amount + 1
            end

        end

        ###Meansures

        ###Tables
        if :table in output
            for (k, measure) in enumerate(measures)
                vmeansure = [stream_names[i]; [measure(CategoricalArray{Int64}(predicted_ys[j]) , stream.labels[stream.n_avaiable_labels+1:end]) for j in 1:n_models]]
                append!(r_output.tables[k], DataFrame(permutedims(vmeansure)))
            end
        end

        if :prequential in output
            points_vector = [Array{Any, 1}() for i in 1:n_models]
            for (j, model) in enumerate(models)
                amount = 1
                next_amount = 0
                for k in 1:steps
                    next_amount = (amount - 1) + prequential_interval[k]
                    push!(points_vector[j], accuracy(CategoricalArray{Int64}(predicted_ys[j][amount:next_amount]), stream.labels[amount+150:next_amount+150]))
                    amount = next_amount + 1
                end
            end
            graph_plot = plot(points_vector, labels=permutedims(model_names), legend=:outertopright)
            push!(r_output.graphs, graph_plot)
        end
    end# END FOR STREAM



    if :bar in output
        for (k, measure) in enumerate(measures)
            ctg = repeat(model_names, inner = n_streams)
            nam = repeat(stream_names, outer = n_models)
            push!(r_output.bars, groupedbar(nam, convert(Array{Float64}, r_output.tables[k][:,2:end]),
                group = ctg, xlabel = "Streams", ylabel = "Measure",
                bar_width = 0.67, lw = 0, framestyle = :box, legend=:outerbottom))
         end
    end


    ###Set tables column names
    if :table in output
        for table in r_output.tables
             names!(table, [Symbol("Stream_Names"); [Symbol(name) for name in model_names]])
        end
    end
    return r_output
end
