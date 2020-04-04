export SetProperty, CLOSED, OPEN
export AbstractVertexSet, Neighbors, Mirrors, Vertex, UnionOf
export NeighborCover, MirrorCover, NearestNeighbors
export vertices, neighbors, neighborcover

# Vertex Set Notations
abstract type AbstractVertexSet end

abstract type SetProperty end
struct CLOSED <: SetProperty end
struct OPEN <: SetProperty end

"""
    Neighbors{SP<:SetProperty, NTH} <: AbstractVertexSet

Neighbors, if `SP` is `CLOSED`, then this set contains vertex itself.
"""
struct Neighbors{SP<:SetProperty, NTH} <: AbstractVertexSet
    i::Int
end

const NearestNeighbors{SP} = Neighbors{SP, 1}
const NeighborCover = Neighbors{CLOSED, 1}

"""
    Mirrors{SP<:SetProperty} <: AbstractVertexSet

Mirrors and itself. A vertex `w` is a mirror of `v` if `w ∈ N²(v)` and `N[v]\\N(w)` is a clique.
"""
struct Mirrors{SP<:SetProperty} <: AbstractVertexSet
    i::Int
end
const MirrorCover{SP} = Mirrors{CLOSED}

struct Vertex<:AbstractVertexSet
    i::Int
end

"""
    UnionOf{TA, TB}<:AbstractVertexSet

A union of ...
"""
struct UnionOf{TA, TB}<:AbstractVertexSet
    A::TA
    B::TB
end
Base.:∪(A::AbstractVertexSet, B::AbstractVertexSet) = UnionOf(A, B)

"""
    neighborcover(eg::EliminateGraph, i::Int)

Get neighbors of vertex `i`, including itself.
"""
function neighborcover end
