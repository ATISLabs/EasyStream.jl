function runS(stream::Stream, model)
    println("Stream")
    fit_result, _, _ = fit(classifier, 0, stream.samples[1:stream.n_avaiable_labels, :], stream.labels[1:stream.n_avaiable_labels, :])
    return update_predict(model, fit_result, stream.samples[stream.n_avaiable_labels+1:end, :], stream.labels[stream.n_avaiable_labels+1:end, :])
end

function runM(stream::Stream, model)
    println("MLJBase")
    MLJBase.machine(model, stream.samples, stream.labels)
    MLJBase.fit!(model, rows=1:stream.n_avaiable_labels)
    return MLJBase.predict(model, row=stream.n_avaiable_labels+1:length(stream.labels)-stream.n_avaiable_labels)
end

#=
function run(stream::Stream, classifier)
next_amount = 0
    amount = 1 + stream.n_avaiable_labels
    iterations = floor((nrows(stream.samples) - stream.n_avaiable_labels) / stream.window_size)
    predicted_y = Array{CategoricalValue{}, 1}()

    fit_result, _, _ = MLJModels.fit(classifier, 0, stream.samples[1:stream.n_avaiable_labels, :], stream.labels[1:stream.n_avaiable_labels, :])

    if iterations > 0
        interations = 1:iterations

        for i in interations
            next_amount = (amount - 1) + stream.window_size

            if typeof(classifier) <: MLJBase.Probabilistic
                append!(predicted_y, predict_mode(classifier, fit_result, stream.samples[amount:next_amount,:]))
            else
                append!(predicted_y, predict(classifier, fit_result, stream.samples[amount:next_amount,:]))
            end

            amount = next_amount + 1
        end
    end
    if nrows(stream.samples) - next_amount != 0
        if typeof(classifier) <: MLJBase.Probabilistic
            append!(predicted_y, predict_mode(classifier, fit_result, stream.samples[next_amount+1:end,:]))
        else
            append!(predicted_y, predict(classifier, fit_result, stream.samples[next_amount+1:end,:]))
        end
    end
    #teste = coerce(predicted_y, Multiclass{})
    return CategoricalArray{}(predicted_y)
end
=#
