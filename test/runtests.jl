using EasyStream
using Test

stream = EasyStream.Dataset1CDT(5)

filter = EasyStream.FilterModifier([:Column1, :Column1])

EasyStream.push!(stream, filter)

EasyStream.listen(stream)




using DataFrames

x = stream.connector.rows[1]



values1 = DataFrame[]

push!(values1, DataFrame(x))

DataFrame(values1)

w = vcat(values1...)


w


select!(w, :Column1)