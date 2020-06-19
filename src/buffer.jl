using CSV
using DataFrames

abstract type Buffer end

struct MemoryBuffer <: Buffer
    data::DataFrame
end

MemoryBuffer(path::String) = MemoryBuffer(CSV.read(path))
Dataset1CDT() = MemoryBuffer("datasets/1CDT.csv")
