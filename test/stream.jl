
@testset "Stream" begin
    @testset "Batch" begin 
        df = EasyStream.DataFrame(x = [1, 2, 3, 4, 5, 6], y = [6, 5, 4, 3, 2, 1])
        conn = EasyStream.TablesConnector(df)
        n_rows = size(df, 1)
        for batch = 1:n_rows
            EasyStream.reset!(conn)
            stream = EasyStream.BatchStream(conn, batch = batch)

            i = 1
            while i <= n_rows
                index = i + batch -  1
                (index > n_rows) && (index = n_rows)
                
                df_row = df[i:index, :]
                stream_next = EasyStream.listen(stream)

                for j = 1:size(df_row, 1)
                    for k = 1:size(df_row, 2)
                        @test stream_next[j, k] == df_row[j, k]
                    end
                end
                i = index + 1
            end
        end

        EasyStream.reset!(conn)
        stream = EasyStream.BatchStream(conn)
        @test stream.event.time == 0

        i = 1
        for stream_next in stream
            df_row = df[i, :]
            for j=1:size(df, 2)
                @test stream_next[1, j] == df_row[j]
            end
            i += 1 
        end
    end
end

