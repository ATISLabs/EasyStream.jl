function run(stream::Stream, classifier)
    amount = 1 + stream.n_avaiable_labels
    next_amount = 0
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
