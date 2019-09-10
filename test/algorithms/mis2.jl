using EliminateGraphs
using Test

@testset "adjacent45" begin
    eg = K_eg(4,5)
    v1, v2 = EliminateGraphs.adjacent45(eg)
    @test Set([degree(eg,v2), degree(eg, v1)]) == Set([4,5])
end

@testset "mis2" begin
    @test EliminateGraphs.minx(x->x^2, [2,-1, 3]) == -1

    g1 = EliminateGraph([0 1 1 0 0;
                         1 0 1 1 0;
                         1 1 0 1 0;
                         0 1 1 0 0;
                         0 0 0 0 0])

    @test mis2(g1) == 3
    g2 = disconnected_cliques_eg(6, 6)
    @test mis2(g2) == 2
    g3 = K_eg(7, 2)
    @test mis2(g3) == 7
    g4 = K_eg(7, 7)
    @test mis2(g4) == 7
    g5 = ring_eg(4)
    @test mis2(g5) == 2
    @test mis2(c60_graph) == 24
    g6 = K_eg(4, 5)
    unsafe_disconnect!(g6, 1,5)
    unsafe_connect!(g6, 2,3)
    @test mis2(g6) == 5
    g7 = K_eg(4, 5)
    @test mis2(g7) == 5

    for i = 1:100
        eg = rand_eg(40, 0.2)
        @test mis1(eg) == mis2(eg)
    end
end
