using EasyStream
using Test

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
