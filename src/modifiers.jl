using Random

abstract type Modifier end

struct Modifiers <: Modifier
    modifiers::Array{Modifier}
end

Modifiers(modifiers::Modifier ...) = Modifiers([modifiers...])

function apply!(modifiers::Modifiers, data::DataFrame, event::Event)
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

function apply!(modifier::NoiseModifier, data::DataFrame, event::Event)
    return nothing
end

struct FilterModifier <: Modifier
    columns::Array{Symbol}
end

#TODO: Verificar se tem colunas duplicatas
FilterModifier(columns::Symbol...) = FilterModifier([columns...])

function apply!(modifier::FilterModifier, data::DataFrame, event::Event)
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

struct AlterDataModifier <: Modifier
    alter!::Function
end

function apply!(modifier::AlterDataModifier, data::DataFrame, event::Event)
    modifier.alter!(data, event)

    return nothing
end
