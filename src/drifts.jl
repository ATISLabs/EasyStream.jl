function DriftModifier(column::Symbol, filter::Function, drift::Function)
    function f(data, event)
        elements = filter(data)
        data[elements, column] = data[elements, column] .+ drift(event)
        return nothing
    end

    return AlterDataModifier(f)
end

sigmoid(x; c1 = 1.0, c2 = 0.0) = 1 / (1 + ℯ ^ (-c1 * (x - c2)))

function IncrementalDriftModifier(vetor::Dict{Symbol, T}, filter::Function; c1 = 1.0, c2 = 0.0)::Modifiers where T <: Number
    modifiers = EasyStream.Modifier[]
    for (column, value) in vetor
        drift = DriftModifier(column, filter, x -> value .* sigmoid(x; c1 = c1, c2 = c2))
        push!(modifiers, drift)
    end

    return Modifiers(modifiers)
end

function SuddenDriftModifier(vetor::Dict{Symbol, T}, filter::Function; c2 = 0.0)::Modifiers where T <: Number
    return IncrementalDriftModifier(vetor, filter; c1 = 1.0, c2 = c2)
end