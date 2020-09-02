@testset "Connector" begin
    @testset "TableConnector" begin
        df = EasyStream.DataFrame(x = [1, 2, 3, 4, 5, 6], y = [6, 5, 4, 3, 2, 1])
        conn = EasyStream.TablesConnector(df)
        
        for i = 1:size(df, 1)
            @test EasyStream.hasnext(conn) == true
            
            batch = EasyStream.next(conn)
            
            for j = 1:size(df, 2)
                @test  batch[1, j] == df[i, j] 
            end
        end
        
        @test EasyStream.hasnext(conn) == false

        @test EasyStream.next(conn) === nothing

        @test length(conn) == size(df, 1)

        EasyStream.reset!(conn)

        @test conn.state == 0

        array = [1 2 3 4 5; 6 7 8 9 10]

        @test_throws ArgumentError EasyStream.TablesConnector(array)
        
        @testset "sort functionalities" begin
            
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
                @test_throws ArgumentError EasyStream.TablesConnector(df, name)
            end
        end

        @testset "shuffle functionalities" begin
            df = DataFrame(x = [1:100 ...])
            
            conn = EasyStream.TablesConnector(df, shuffle = true)
            diff_elements = 0

            for x in df[:, :x]
                batch = EasyStream.next(conn)
                if batch[1, :x] != x
                    diff_elements += 1
                end
            end

            @test diff_elements > 0
        end
    end

    @testset "Generator Connector" begin
        function generator(n_features::Int)        
            return DataFrame(permutedims([rand() for _ = 1:n_features ]))
        end
        
        n_features = 5
        conn = EasyStream.GeneratorConnector(generator, n_features)
        
        data = EasyStream.next(cnn)
        
        @test size(data, 1) == 1
        @test size(data, 1) == n_features
        
    end
end