function prequential_plots(measure_set::MeasureSet, output)
    used_measures = collect(delete!(Set(copy(output)), output[1]))

    graphs = []
    base = []
    measure_set.sizes[:measure] = length(output) - 1
    measure_set.names[:measure] = used_measures

    for l in 1:measure_set.sizes[format[3]]
        position = Dict(format[3] => l)
        push!(base, [])
        for i in 1:measure_set.sizes[format[2]] ###format[3] ###here will have a for to represent the tables
            push!(base[l], DataFrame())
            position[format[2]] = i
            #for j in 1:measure_set.sizes[format[1]] ### format[1] ###Rows
            #position[format[1]] = j
            for j in 1:measure_set.steps
                vmeansure = []
                for k in 1:measure_set.sizes[format[1]] ##format[2] ###Columns
                    position[format[1]] = k
                    push!(vmeansure, measure_set.calculated_measures[position[:stream]][position[:model]][j][used_measures[position[:measure]]])
                end
                append!(base[l][i], DataFrame(permutedims(vmeansure)))
            end
        end

        push!(graphs, [])
        for (j, _table) in enumerate(base[l])
            push!(graphs[l], plot(convert(Array{Float64}, _table),
            labels = permutedims(measure_set.names[:model]),
            title  = measure_set.names[:stream][j],
            xlabel = "Steps",
            ylabel = measure_set.names[:measure][l]))
        end
    end

    return graphs
end
