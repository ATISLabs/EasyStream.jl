using Random

abstract type Modifier end

struct Modifiers <: Modifier
    modifiers::Array{Modifier}
end

Modifiers(modifiers::Modifier ...) = Modifiers([modifiers...])

function apply!(modifiers::Modifiers, data::DataFrame, event::Int)
    for modifier in modifiers.modifiers
        apply!(modifier, data, event)
    end

    return nothing
end

struct NoiseModifier <: Modifier
    seed::Random.MersenneTwister
    attribute::Float64 # The fraction of attribute values to disturb
end

NoiseModifier(attribute::Float64, seed::Int) = NoiseModifier(Random.seed!(seed), attribute)
NoiseModifier(attribute::Float64) = NoiseModifier(andom.default_rng(), attribute)

function apply!(modifier::NoiseModifier, data::DataFrame, event::Int)
    return nothing
end

struct FilterModifier <: Modifier
    columns::Array{Symbol}
end

#TODO: Verificar se tem colunas duplicatas
FilterModifier(columns::Symbol...) = FilterModifier([columns...])

function apply!(modifier::FilterModifier, data::DataFrame, event::Int)
    columns = Symbol[]
    for col in modifier.columns
        if !(col in propertynames(data))
            #TODO: Colocar para avisar somente uma única vez do problema.
            @warn "O stream não possui a $col"
        else
            push!(columns, col)
        end
    end

    select!(data, columns)
    return nothing
end

struct DriftModifier <: Modifier
    column::Symbol
    filter::Function
    drift::Function
end

function apply!(modifier::DriftModifier, data::DataFrame, event::Int)
    elements = modifier.filter(data)
    data[elements, modifier.column] = data[elements, modifier.column] .+ modifier.drift(event)

    return nothing
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