using Test
using EasyStream


@testset "Module DataStreams" begin
    test_file = "moduletest.csv"
    @test EasyStream.DataStreams.check(test_file) == 0 
    @test EasyStream.DataStreams.download("https://github.com/Conradox/datastreams/blob/master/sinthetic/moduletest.csv", "moduletest.csv") == 1
    @test EasyStream.DataStreams.check(test_file) == 1
    rm(EasyStream.DataStreams.DataStreams.local_path * '/' * test_file)
end


@testset "Stream Test" begin
    stream = EasyStream.Dataset1CDT()
    @test size(EasyStream.next!(stream), 1) == 150
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
