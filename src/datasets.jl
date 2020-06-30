using CSV

Dataset1CDT() = Dataset1CDT(150, 1)

function Dataset1CDT(initial_size::Int, flux_size::Int)
    data = CSV.read("../datasets/1CDT.csv"; header = false)
    return MemoryBuffer(data, initial_size, flux_size)
end
