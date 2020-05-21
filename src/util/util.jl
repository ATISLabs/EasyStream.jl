function interval(size, steps)
    _size = size
    amount = _size
    interval = Int64(floor(amount / steps))
    prequential_interval = [ interval for k in 1:steps ]
    amount -= steps * interval
    for k in 1:amount
        prequential_interval[k % steps] += 1
    end
    return prequential_interval
end

function output_validate(vector)
    validation = Dict()
    typeGraphs = [:prequential, :bar]

    validation[:table] = collect(keys(measures))
    validation[:graph] = typeGraphs
    for typeGraph in typeGraphs
        validation[typeGraph] = measures
    end
    for measure in validation[:table]
        validation[measure] = validation[:table]
    end

    for i in 1:length(vector)-1
        if vector[i+1] in validation[vector[i]]
        else
            throw("Error in some output vector")
        end
    end
    println("Output validated")
end

function setformat(format)
    global _format = format
end
