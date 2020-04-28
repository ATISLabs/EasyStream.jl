"""
    distributionByClass(xg, yg, pred, predicted_y; colors = [:pink, :lightblue])

Generates a graph plotting the samples and shows the spatial limit for what the model considers contained in each class.

`X` is the variable contains the points to be ploted in the scatter and `predicted_y` determine the classes of these points.

Variables `xg` and `xy` determine the grid of the space. More points contained in these variables mean a more detailed space.

Variable `pred` contains the model that will be used to determined the spacial classification.
"""
function distributionByClass(model, fitresult, xg, yg, X, predicted_y; colors = [:pink, :lightblue])
    pred(x, y) = convert(Int64, predict(model, fitresult, [x, y]))
    graph = heatmap(xg, yg, pred, c = cgrad(colors))
    scatter!(X[:,1], X[:,2], c = Array{Int64}(predicted_y), palette = colors, leg = false)
    return graph
end

function distributionByClass(model, fitresult, X, predicted_y; colors = [:pink, :lightblue], granularity = 50)
    pred(x, y) = convert(Int64, predict(model, fitresult, [x, y]))
    xg = range(minimum(X[:,1]), maximum(X[:,1]), length = granularity)
    yg = range(minimum(X[:,2]), maximum(X[:,2]), length = granularity)

    graph = heatmap(xg, yg, pred, c = cgrad(colors))
    scatter!(X[:,1], X[:,2], c = Array{Int64}(predicted_y), palette = colors, leg = false)
    return graph
end

function distributionByClass(stream, model; steps = 1, colors = [:pink, :lightblue], granularity = 50)
    fitresult, _, _ = fit(model, 0, stream.samples[1:stream.n_avaiable_labels], stream.labels[1:stream.n_avaiable_labels])
    pred(x, y) = convert(Int64, predict(model, fitresult, [x, y]))
    xg = range(minimum(X[:,1]), maximum(X[:,1]), length = granularity)
    yg = range(minimum(X[:,2]), maximum(X[:,2]), length = granularity)

    graph = heatmap(xg, yg, pred, c = cgrad(colors))
    scatter!(X[:,1], X[:,2], c = Array{Int64}(predicted_y), palette = colors, leg = false)
    return graph
end
"""
    prequentialAnalyze(ŷ, y, steps, meansure)

Generates a graph plotting the results of the meansure on intervals of time defined to a determined number of smaples `length(ŷ)` / `steps`.

`ŷ` and `y` are the values wich will be used in the meansure function to be result the plot points.

`steps` defines how much grainy will be the graph.

"""
function prequentialAnalyze(ŷ, y, steps, meansure)
    if length(ŷ) == length(y)
        amount = 1
        next_amount = 0
        for k in 1:steps
            next_amount = (amount - 1) + prequential_interval[k]
            push!(points_vector[j], accuracy(CategoricalArray{Int64}(predicted_ys[j][amount:next_amount]), stream.labels[amount:next_amount]))
            amount = next_amount + 1
        end
    end
    graph = plot(points_vector, labels=permutedims(model_names), legend=:outertopright)
    return graph
end
