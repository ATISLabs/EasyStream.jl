using CSV

const defdir = joinpath(dirname(@__FILE__), "..", "datasets")

function get1cdtdata(dir)
       mkpath(joinpath(defdir, "synthetic"))
       path = download("https://raw.githubusercontent.com/Conradox/datastreams/master/sinthetic/1CDT.csv")
    mv(path, joinpath(defdir, "synthetic/1CDT.csv"))
end

function getug2c5ddata(dir)
    mkpath(joinpath(defdir, "synthetic"))
    path = download("https://raw.githubusercontent.com/Conradox/datastreams/master/sinthetic/UG_2C_5D.csv")
    mv(path, joinpath(defdir, "synthetic/UG_2C_5D.csv"))
end

function Dataset1CDT(batch::Int)::BatchStream
    filename = "$(defdir)/synthetic/1CDT.csv"

    isfile(filename) || get1cdtdata(defdir)

    data = CSV.read(filename; header = false)

    conn = EasyStream.TablesConnector(data)

    stream = BatchStream(conn; batch = batch)

    return stream
end

Dataset1CDT() = Dataset1CDT(1)

function DatasetUG_2C_5D(batch::Int)::BatchStream
    filename = "$(defdir)/synthetic/UG_2C_5D.csv"

    isfile(filename) || getug2c5ddata(defdir)

    data = CSV.read(filename; header = false)

    conn = EasyStream.TablesConnector(data)

    stream = BatchStream(conn, batch)

    return stream
end

DatasetUG_2C_5D() = DatasetUG_2C_5D(1)