function DriftModifier(filter::Function, drift::Function)
    function f(data, event)
        elements = filter(data)

        if length(elements) > 0
            df = @view data[elements, :]
            drift(df, event)
        end
        return nothing
    end

    AlterDataModifier(f)
end

sigmoid(x; c1 = 1.0, c2 = 0.0) = 1 / (1 + ℯ ^ (-c1 * (x - c2)))

function ClassDriftModifier(column::Symbol, value::T, drift::Function) where T <: Number
    return DriftModifier((data) -> findall(r-> r == value, data[:, column]), drift)
end

function IncrementalDriftModifier(vetor::Dict{Symbol, T}, filter::Function; c1 = 1.0, c2 = 0.0)::Modifiers where T <: Number
    modifiers = EasyStream.Modifier[]
    for (column, value) in vetor
        drift = DriftModifier(filter, (data, event) -> 
                                        data[:, column] = data[:, column] .+ value .* sigmoid(event.time; c1 = c1, c2 = c2))
        push!(modifiers, drift)
    end

    return Modifiers(modifiers)
end

function SuddenDriftModifier(vetor::Dict{Symbol, T}, filter::Function; c2 = 0.0)::Modifiers where T <: Number
    return IncrementalDriftModifier(vetor, filter; c1 = 1.0, c2 = c2)
end