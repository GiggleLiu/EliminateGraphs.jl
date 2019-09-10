using Test
using EliminateGraphs

@testset "graphlib" begin
    # random graph
    eg = rand_eg(10, 0.5)
    @test check_validity(eg)
    @test eg isa EliminateGraph
    @test nv(eg) == nv0(eg) == 10

    # empty and full graph
    g = empty_eg(10)
    @test check_validity(eg)
    @test nv(g) == 10
    @test ne(g) == 0
    g = K_eg(4)
    @test check_validity(eg)
    @test ne(g) == 6
    g = K_eg(3,3)
    @test check_validity(eg)
    @test nv(g) == 6
    @test ne(g) == 9
    g =  disconnected_cliques_eg(3,3)
    @test check_validity(eg)
    @test nv(g) == 6
    @test ne(g) == 6

    # chain and ring
    g = chain_eg(10)
    @test check_validity(eg)
    @test nv(g) == 10
    @test ne(g) == 9
    g = ring_eg(10)
    @test check_validity(eg)
    @test nv(g) == 10
    @test ne(g) == 10

    # constant graphs
    @test check_validity(petersen_graph)
    @test petersen_graph |> ne == 15
    @test petersen_graph |> nv == 10
    @test check_validity(c60_graph)
    @test c60_graph |> ne == 90
    @test c60_graph |> nv == 60
end
