using Test
using EasyStream
using Plots, StatsPlots
@testset "EasyStream" begin
    # Write your own tests here.
    @load KNNClassifier
    @load DecisionTreeClassifier
    path = "../datasets/sinthetic/"
    window_size = 2000
    n_avaiable_labels = 150
    ###Getting data
    streams = Array{Any, 1}()
    name_files = split(read(`ls $path`, String), "\n")[1:end-1];
    for name_file in name_files
        dataset = load(path * name_file, header_exists=false) |> DataFrame
        dataset = coerce(dataset, autotype(dataset))
        samples = Matrix{Float64}(dataset[:,1:end-1])
        labels = categorical(dataset[:,end])
        push!(streams, EasyStream.Stream(window_size, n_avaiable_labels, samples, labels, name = name_file))
    end
    EasyStream.prequential_evaluate(
    [streams[1], streams[2], streams[3]],
    [KNNClassifier(), DecisionTreeClassifier()])

end
