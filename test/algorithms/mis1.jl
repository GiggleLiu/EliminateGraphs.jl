using EliminateGraphs, EliminateGraphs.Graphs
using Test

@testset "mis1" begin
    @test EliminateGraphs.minx(x->x^2, [2,-1, 3]) == -1

    graph = EliminateGraph([0 1 0 0 0;
                            1 0 1 1 0;
                            0 1 0 1 0;
                            0 1 1 0 1;
                            0 0 0 1 0])

    @test mis1(graph) == 3
end

@testset "mis1e" begin
    graph = EliminateGraph([0 1 0 0 0;
                            1 0 1 1 0;
                            0 1 0 1 0;
                            0 1 1 0 1;
                            0 0 0 1 0])

    alpha, sets = mis1e(graph)
    @test alpha == 3
    sets = sort(sort.(collect.(sets)))
    @test sets == [[1, 3, 5]]

    graph = EliminateGraph(smallgraph(:petersen))
    alpha, sets = mis1e(graph)
    @test alpha == 4
    @test length(sets) == 5
    sets = sort(sort.(collect.(sets)))
    @test sets == [[1, 3, 9, 10], [1, 4, 7, 8], [2, 4, 6, 10], [2, 5, 8, 9], [3, 5, 6, 7]]
end