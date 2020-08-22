using EasyStream
using Test

@testset "sort and shuffle functionalities" begin
    df = EasyStream.DataFrame(x = [1, 2, 3, 4, 5, 6], y = [6, 5, 4, 3, 2, 1])
    
    cnn = EasyStream.TablesConnector(df, :y)
    for x in df[:,1]
        @test EasyStream.next(cnn)[2][1] == x
    end

    cnn = EasyStream.TablesConnector(df, :x, rev = true)
    for y in df[:,2]
        @test EasyStream.next(cnn)[1][1] == y
    end

    missing_names = [:c, :d, :e]
    for name in missing_names
        @test_logs (:warn,"A tabela não possui a coluna $name") EasyStream.TablesConnector(df, name)
     end
end
