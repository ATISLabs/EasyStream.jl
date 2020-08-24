using EasyStream
using DataFrames
using Test

@testset "sort functionalities" begin
    df = DataFrame(x = [1, 2, 3, 4, 5, 6], y = [6, 5, 4, 3, 2, 1])
    
    conn = EasyStream.TablesConnector(df, :x)
    for x in df[:, :x]
        batch = EasyStream.next(conn)
        @test batch[1, :x] == x
    end

    conn = EasyStream.TablesConnector(df, :x, rev = true)
    for x in df[:, :x]
        batch = EasyStream.next(conn)
        @test batch[1, :y] == x
    end

    missing_names = [:w, :column]
    for name in missing_names
        @test_logs (:warn,"The dataset doesn't have the column $name") EasyStream.TablesConnector(df, name)
     end
end
