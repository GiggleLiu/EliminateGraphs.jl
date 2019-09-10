using Test
using EliminateGraphs

@testset "Vertex set" begin
    @test Vertex(3) ∪ NeighborCover(4) isa UnionOf{Vertex, NeighborCover}
end
