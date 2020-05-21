"""
    makebars(measure_set::MeasureSet, output)

This function is used to create a graph bar for analyze using a MeasureSet
and an output struct.

**Arguments**
* `measureset` is a variable that need to receive a MeasureSet struct. That structure stores the measures of model performances over streams and it is returned by `EasyStream.evaluate`
* `output` is defined as an array containing the type of the output and the measures that will be used. For instance
    [:graph, :accuracy], [:table, :time] and [:table, :time, accuracy]

**Examples**
```julia
measures = EasyStream.evaluate(
streams[1:3], #Streams
[KNNClassifier(), DecisionTreeClassifier()], #Models
measures = [:time, :accuracy]); #Measures

tables = makebars.generate(measures, [:table, :accuracy, :time])
```
"""
function makebars(measure_set::MeasureSet, output)
    used_measures = collect(delete!(Set(copy(output)), output[1]))

    bar_graphs = []
    base = []
    measure_set.sizes[:measure] = length(output) - 1
    measure_set.names[:measure] = used_measures

    for i in 1:measure_set.sizes[format[3]]  ###format[3]
        push!(base, DataFrame())
    end
    for i in 1:measure_set.sizes[format[3]] ###format[3] ###here will have a for to represent the tables
        position = Dict(format[3] => i)
        for j in 1:measure_set.sizes[format[1]] ### format[1] ###Rows
            position[format[1]] = j
            vmeansure = []
            for k in 1:measure_set.sizes[format[2]] ##format[2] ###Columns
                position[format[2]] = k
                push!(vmeansure, measure_set.calculated_measures[position[:stream]][position[:model]][used_measures[position[:measure]]])
            end
            append!(base[i], DataFrame(permutedims(vmeansure)))
        end
    end

    for (i, _table) in enumerate(base)
        ctg = repeat(measure_set.names[format[1]], inner = measure_set.sizes[format[2]])
        nam = repeat(measure_set.names[format[2]], outer = measure_set.sizes[format[1]])
        x_nam = string(format[2]) * "s"
        x_nam = uppercase(x_nam[1]) * x_nam[2:end]
        _title = string(measure_set.names[format[3]][i])
        _title = uppercase(_title[1]) * _title[2:end]
        push!(bar_graphs, groupedbar(nam, convert(Array{Float64}, _table),
            group = ctg, xlabel = x_nam, title = _title,
            bar_width = 0.67, lw = 0, framestyle = :box))
     end
     return bar_graphs
 end
