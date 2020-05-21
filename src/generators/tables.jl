"""
    maketables(measureset::MeasureSet, output)

This function is used to create tables for analyze using a MeasureSet
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

tables = maketables.generate(measures, [:table, :accuracy, :time])
```
"""
function maketables(measureset::MeasureSet, output)
    table_vector = []

    used_measures = collect(delete!(Set(copy(output)), output[1]))

    measureset.sizes[:measure] = length(output) - 1
    measureset.names[:measure] = used_measures

    for i in 1:measureset.sizes[format[3]]  ### format[3] defines the criterio of dividing over tables
        push!(table_vector, DataFrame())    ### creating a dataframe to represent each table
    end

    for i in 1:measureset.sizes[format[3]]  ### The outermost in the creating of tables
        position = Dict(format[3] => i)
        for j in 1:measureset.sizes[format[1]] ### format[1] defines the criterio of dividing over rows
            position[format[1]] = j
            row = []
            push!(row, measureset.names[format[1]][j])
            for k in 1:measureset.sizes[format[2]] ### format[2] defines the criterio of dividing over columns
                position[format[2]] = k
                push!(row, measureset.calculated_measures[position[:stream]][position[:model]][used_measures[position[:measure]]])
            end
            append!(table_vector[i], DataFrame(permutedims(row)))
        end
        rename!(table_vector[i], [format[1]; [Symbol(name) for name in measureset.names[format[2]]]])
    end
    return table_vector
end
