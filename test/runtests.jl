using EasyStream
using Test

using CSV
using Tables

const defdir = joinpath(dirname(@__FILE__), "..", "datasets")

filename = "$(defdir)/synthetic/UG_2C_5D.csv"

conn = EasyStream.TablesConnector(filename)

source = EasyStream.BatchStream(conn, 5)

a= EasyStream.listen(source)


using DataFrames

DataFrame(a)

using CSV

CSV.File(filename; header = false)