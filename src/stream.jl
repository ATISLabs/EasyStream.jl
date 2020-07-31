struct Stream
    source::AbstractSource
    data_tables::Vector
end

Stream(source::AbstractSource) = Stream(source, Vector{Any}())

function next(stream::Stream; f::Function = copyall)
    data = next(stream.source)

    elements = f(size(data)[1], length(stream.data_tables))

    for i=1:length(stream.data_tables)
        println(table_publish(stream.data_tables[i], data[elements[:, i], :]))
        stream.data_tables[i] = table_publish(stream.data_tables[i], data[elements[:, i], :])
    end
end

copyall(qnt_elements, qnt_tables) = ones(Bool, qnt_elements, qnt_tables)

function publish(stream::Stream, data_tables...)
    for data_table in data_tables
        push!(stream.data_tables, data_table)
    end
end

function table_publish(table, arrived_data)
    base_type = typeof(table)
    other_type = typeof(arrived_data)
    if base_type != other_type 
        arrived_data = convert(base_type, arrived_data)
    end
    return vcat(table, arrived_data)
end

