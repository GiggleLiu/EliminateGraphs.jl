using Test
using EliminateGraphs
using LightGraphs

@testset "constructors and properties" begin
    tbl = Bool[false true false false; true false true true; false true false true; false true true false]
    eg = EliminateGraph(tbl)
    @test check_validity(eg)
    @test eg == EliminateGraph(4,[1=>2, 2=>3,2=>4,3=>4])
    @test collect(vertices(eg)) == collect(1:4)

    @test subgraph(disconnected_cliques_eg(3,4), [1,2,3]) == K_eg(3)
    @test subgraph(K_eg(3,4), [1,2,3]) == empty_eg(3)
end

@testset "neighbors" begin
    tbl = Bool[false true true false; true false true true; false true false true; true true true false]
    eg = EliminateGraph(tbl .& tbl')
    @show eg
    nbs = neighbors(eg, 1)
    @test nbs == [2]
    @test neighbors2(eg, 1) == [3,4]
    @test neighborcover(eg, 1) == [1,2]
    @test nv(eg) == 4
end

@testset "degree" begin
    tbl = Bool[false true true false; true false true true; false true false true; true true true false]
    eg = EliminateGraph(tbl .& tbl')
    @test degrees(eg) == [1, 3, 2, 2]

    vs = vertices(eg)
    @test [vs...] == vertices(eg)
    @test vs[3] == vertices(eg)[3]
    vmin, dmin = mindegree_vertex(eg)
    @test degree(eg, vmin) == minimum(degrees(eg)) == dmin
    vmax, dmax = maxdegree_vertex(eg)
    @test degree(eg, vmax) == maximum(degrees(eg)) == dmax
    vmin, vmax, dmin, dmax = minmaxdegree_vertex(eg)
    @test degree(eg,vmin) == minimum(degrees(eg)) == dmin
    @test degree(eg,vmax) == maximum(degrees(eg)) == dmax
end

@testset "vertices and neighbors - eliminated" begin
    tbl = Bool[false true true false; true false true true; false true false true; true true true false]
    eg = EliminateGraph(tbl .& tbl')
    eliminate!(eg, 2)
    eliminate!(eg, 3)
    @test nv(eg) == 2
    recover!(eg)
    @test nv(eg) == 3
    eg2 = eg \ 3
    @test nv(eg) == 3
    @test nv(eg2) == 2
    @test vertices(eg2) == [1,4]
    @test neighbors(eg2, 1) == []
    @test degrees(eg) == [1, 0, 1]
    @test degrees(eg2) == [0, 0]
    eg3 = eg2 \ (1,4)
    @test nv(eg3) == 0
end

@testset "eliminate and recover" begin
    tbl = Bool[false true true false; true false true true; false true false true; true true true false]
    eg = EliminateGraph(tbl .& tbl')
    @test check_validity(eg)
    res = eliminate(eg, 3) do eg
        @test check_validity(eg)
        nv(eg)
    end # do
    @test res == 3

    eg4 = eg \ NeighborCover(1)
    @test vertices(eg4) == [3,4]

    res = eliminate(eg, (3,4)) do eg
        @test check_validity(eg)
        eliminate(eg, (1,2)) do eg
            @test check_validity(eg)
            nv(eg)
        end
    end
    @test res == 0
    @test nv(eg) == 4
    @test eg.level == 0
end

@testset "cluster and clique" begin
    # isclique
    g = disconnected_cliques_eg(3,4)
    @test isclique(g, [1,2,3])
    @test !isclique(g, [1,2,4])
    @test !isclique(g)

    # findcluster
    @test find_cluster(g, 1) == [1,2,3]
    @test find_cluster(g, 4) == [4,5,6,7]
    @test find_cluster(petersen_graph, 1) == collect(1:10)

    # is connected
    @test !isconnected(g)
    @test isconnected(petersen_graph)

    g = K_eg(3)
    @test isclique(g)
end

@testset "mirrors" begin
    @test mirrors(petersen_graph, 1) == []
    @test mirrorcover(petersen_graph, 1) == [1]

    g = K_eg(3,3)
    @test Set(mirrorcover(g, 1)) == Set([1,2,3])
    @test Set(mirrorcover(g, 4)) == Set([4,5,6])

    eliminate(g, MirrorCover(1)) do eg
        @test check_validity(eg)
        @test Set(vertices(eg)) == Set([4,5,6])
    end
    @test g == K_eg(3,3)

    @test generate_set(g, Mirrors{OPEN}(1) ∪ Vertex(1)) == generate_set(g, MirrorCover(1))
end

@testset "convert" begin
    g = K_eg(3,3)
    sg = SimpleGraph(g)
    g2 = sg |> EliminateGraph
    @test g == g2
end
