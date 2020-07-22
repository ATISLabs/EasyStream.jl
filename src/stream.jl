struct Stream
    source::AbstractSource
    data_tables::Vector
end

Stream(source::AbstractSource) = Stream(source, Vector{Any}())

function next(stream::Stream; f::Function = copyall)
    data = next(stream.source)

    elements = f(size(data)[1], length(stream.data_tables))

    for i=1:length(stream.data_tables)
        append!(stream.data_tables[i], data[elements[:, i], :])
    end
end

copyall(qnt_elements, qnt_tables) = ones(Bool, qnt_elements, qnt_tables)

function publish(stream::Stream, data_tables...)
    for data_table in data_tables
        push!(stream.data_tables, data_table)
    end
end
