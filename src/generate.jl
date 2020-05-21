"""
    generate(measureset::MeasureSet, outputs...)

`EasyStream.generate` is a function that can receive a group of outputs and along with the
MeasureSet struct it performs the creation of the desired elements to analyzes.

**Arguments**
* `measureset` is a variable that need receiving a MeasureSet struct, such struct is returned by `EasyStream.evaluate` storing the measures of model performances over streams
* `outputs` is a sequence of outputs. Each output is understood as an array containing the type of the output and the measures that will be used. For instance
    [:graph, :accuracy], [:table, :time] and [:table, :time, accuracy]

**Examples**
```julia
measures = EasyStream.evaluate(
streams[1:3], #Streams
[KNNClassifier(), DecisionTreeClassifier()], #Models
measures = [:time, :accuracy]); #Measures

outputs = EasyStream.generate(measures, [:table, :accuracy], [:grap h, :accuracy])
```
"""
function generate(measureset::MeasureSet, outputs...)
    output_vector = [[] for i in 1:length(outputs)]

    for (i, output) in enumerate(outputs)
        ### Checking if there exist a measure in the output that wasn't still calculated
        new_measures = []
        for measure in output[2:end]
            if(!(measure in measureset.measures))
                push!(new_measures, measure)
            end
        end

        ### Calculating new measures
        if measureset.steps == 1 && length(new_measures) > 0
            println("Calculating new measures...")
            measure_calculate(measureset, new_measures)
        end

        ### Generating outputs -> Tables or Graphs
        println(measureset.steps)
        if measureset.steps > 1
            if :graph in output
                append!(output_vector[i], prequential_plots(measureset, output))
            end
        elseif measureset.steps == 1
            if :table in output
                append!(output_vector[i], maketables(measureset, output))
            elseif :graph in output
                append!(output_vector[i], makebars(measureset, output))
            end
        end
    end
    return output_vector
end
