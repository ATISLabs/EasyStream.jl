using Revise

Pkg.activate(".")

using EasyStream

stream = EasyStream.Dataset1CDT()

stream

pool[150,:]

EasyStream.next!(stream)

stream[1,:]


using DataFrames

function createdummydatasetone()
    df = DataFrame()
    df[:user] = [1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7]
    df[:item] = [1, 1, 3, 4, 5, 6, 1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 6, 1, 2, 4, 5, 6, 2, 4, 5]
    df[:rating] = [2.5, 3.5, 3.0, 3.5, 2.5, 3.0, 3, 3.5, 1.5, 5, 3, 3.5, 2.5, 3.0, 3.5, 4.0, 3.5, 3.0, 4.0, 2.5, 4.5, 3.0, 4.0, 2.0, 3.0, 2.0, 3.0, 3.0, 4.0, 5.0, 3.5, 3.0, 4.5, 4.0, 1.0]
    return df
end

df = createdummydatasetone()
EasyStream.Source(df, 100, 10)

using CSV

data = CSV.read("datasets/synthetic/1CDT.csv"; header = true)

data = CSV.File("datasets/synthetic/1CDT.csv"; header = false)

data = CSV.Rows("datasets/synthetic/1CDT.csv"; header = true, ignoreemptylines = true)
data
for row in CSV.Rows("datasets/synthetic/1CDT.csv")
    println("$row")
    break
end

using Revise
using EasyStream
using CSV
using DataFrames

data = CSV.read("datasets/synthetic/1CDT.csv"; header = false)
source = EasyStream.Source(data, 10, 5)

stream = EasyStream.Stream(source)

table1 = Vector()

EasyStream.publish(stream, table1)
stream.data_tables

EasyStream.next(stream)
length(table1)

table1[1]