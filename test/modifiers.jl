@testset "FilterModifier" begin

    df = DataFrame(x = [1, 2, 3, 4, 5, 6], y = [6, 5, 4, 3, 2, 1], z = [6, 5, 4, 3, 2, 1])
    conn_df = EasyStream.TablesConnector(df);
    stream = EasyStream.BatchStream(conn_df; batch = 2);

    filter = EasyStream.FilterModifier([:x, :y])
    push!(stream, filter)

    stream_filtered = EasyStream.listen(stream)

    @test (:x in propertynames(stream_filtered)) == true
    @test (:y in propertynames(stream_filtered)) == true
    @test (:z in propertynames(stream_filtered)) == false

    filter = EasyStream.FilterModifier(:x)
    push!(stream, filter)

    stream_filtered = EasyStream.listen(stream)

    @test (:x in propertynames(stream_filtered)) == true
    @test (:y in propertynames(stream_filtered)) == false
    @test (:z in propertynames(stream_filtered)) == false

    @test_logs (:warn, "There are duplicate columns.") EasyStream.FilterModifier([:x, :x, :y])
    @test_logs (:warn, "There are duplicate columns.") EasyStream.FilterModifier(:x, :x, :y)


    df = DataFrame(x = [1, 2, 3, 4, 5, 6], y = [6, 5, 4, 3, 2, 1], z = [6, 5, 4, 3, 2, 1])
    conn_df = EasyStream.TablesConnector(df, timestamp = true);
    stream = EasyStream.BatchStream(conn_df; batch = 2);

    @test size(EasyStream.listen(stream), 2) == 4
        
end
