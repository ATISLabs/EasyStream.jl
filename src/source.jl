using Tables

abstract type AbstractSource end

mutable struct Source <: AbstractSource
    table
    position::Int
    initial_size::Int
    batch::Int
end

function Source(table, initial_size::Int, batch::Int)
    if !Tables.istable(table)
        @error "não é um tipo table"
    end

    if initial_size > size(table, 1)
        initial_size = size(table, 1)
        @warn "initial size é maior que o arquivo e será definido para o tamanho do arquivo"
    end

    if initial_size == 0
        @warn "initial size é zero"
    end

    if batch == 0
        @warn "flux size é zero"
    end

    return Source(table, 0, initial_size, batch)
end

function next(source::Source)
    if source.position < source.initial_size
        source.position = source.initial_size
        return source.table[1:source.initial_size, :]
    end

    if source.position >= size(source.table, 1)
        return nothing
    end

    if source.position < source.initial_size
        source.position = source.initial_size
        index = 1:source.initial_size
    else
        index = (source.position + 1):(source.position + source.batch)
        source.position = source.position + source.batch
    end

    return source.table[index, :]
end