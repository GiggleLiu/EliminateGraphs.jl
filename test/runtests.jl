using EliminateGraphs
using Test

@testset "Core" begin
    include("Core.jl")
end

@testset "Graph" begin
    include("Graph.jl")
end

@testset "graphlib" begin
    include("graphlib.jl")
end

@testset "mis1" begin
    include("algorithms/algorithms.jl")
end
