@testset "Others" begin
    @testset "Range" begin
        elements = 10
        range_size = 5

        df = DataFrame(x = [1:elements ...], y = [1:elements ...])
        conn = TablesConnector(df)
        stream = BatchStream(conn)
        
        counter = 0
        for sample in Range(range_size, df)
            counter += 1
        end

        @test counter == range_size
    end
end