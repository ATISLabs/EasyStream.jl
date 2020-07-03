using Test
using EasyStream

@testset "Dataset Test" begin
    pool = EasyStream.Dataset1CDT() |> EasyStream.Pool
    @test size(pool[:], 1) == 150

    initial_size = 200
    flux_size = 5
    pool = EasyStream.Dataset1CDT(initial_size, flux_size) |> EasyStream.Pool
    @test size(pool[:], 1) == 200

    pool = EasyStream.DatasetUG_2C_5D() |> EasyStream.Pool
    @test size(pool[:], 1) == 150

    initial_size = 200
    flux_size = 5
    pool = EasyStream.DatasetUG_2C_5D(initial_size, flux_size) |> EasyStream.Pool
    @test size(pool[:], 1) == 200
end

@testset "Stream Test" begin
    stream = EasyStream.Dataset1CDT()
    @test size(EasyStream.next!(stream), 1) == 150
    x = EasyStream.next!(stream)

    @test size(EasyStream.next!(stream), 1) == 1
    @test size(EasyStream.next!(stream), 1) == 1

    initial_size = 200
    flux_size = 5
    stream = EasyStream.Dataset1CDT(initial_size, flux_size)
    @test size(EasyStream.next!(stream), 1) == initial_size
    @test size(EasyStream.next!(stream), 1) == flux_size
    @test size(EasyStream.next!(stream), 1) == flux_size

    initial_size = 16000
    flux_size = 1
    stream = EasyStream.Dataset1CDT(initial_size, flux_size)
    @test size(EasyStream.next!(stream), 1) == initial_size
    @test EasyStream.next!(stream) == nothing

    initial_size = 16001
    flux_size = 1
    stream = EasyStream.Dataset1CDT(initial_size, flux_size)
    @test size(EasyStream.next!(stream), 1) == initial_size - 1
    @test EasyStream.next!(stream) == nothing

    @test_logs (:warn, "initial size é zero") EasyStream.Dataset1CDT(0, 1)
    @test_logs (:warn, "flux size é zero") EasyStream.Dataset1CDT(1, 0)
end

@testset "Pool Indexing" begin
    @testset "Test using one index" begin
        pool = EasyStream.Dataset1CDT() |> EasyStream.Pool
        test_data = pool.data[1]

        data_size = size(test_data, 1)
        for i=1:data_size
            @test pool[i] == test_data[i,:]
        end

        @test pool[:] == test_data[:, :]

        for i=1:data_size
            @test pool[1:i] == test_data[1:i,:]
        end

        ## Testing mapper
        counter = pool.stream.initial_size
        for i=1:20
            EasyStream.next!(pool)
            if pool.mapping[i+1][1]
                counter += 1
            end
            @test size(pool[:], 1) == counter
        end


        #@test_throws BoundsError pool[-1]

        #@test_throws BoundsError pool[data_size + 1]
    end

    @testset "Test using two index " begin
        pool = EasyStream.Dataset1CDT() |> EasyStream.Pool

        @test pool[1, :]== pool[1]

        for i=1:length(pool[1])
            @test pool[1, i] == pool[1][i]
        end

        for i=1:length(pool[1])
            @test pool[:, i] == pool[:][:, i]
        end

        @test pool[:] == pool[:, :]

        #TODO Criação de testes unitários para o acesso ao pool usando range
        #=
        N_INSTANCES = size(pool[:], 1)
        N_FEATURES = length(pool[1])

        @test_throws BoundsError pool[1, N_FEATURES + 1]
        @test_throws BoundsError pool[:, N_FEATURES + 1]
        @test_throws BoundsError pool[N_INSTANCES + 1, :]

        @test_throws BoundsError pool[1, -1]
        @test_throws BoundsError pool[:, -1]
        @test_throws BoundsError pool[-1, :]
        =#
    end

end
