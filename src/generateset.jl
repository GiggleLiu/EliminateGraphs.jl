export neighborcover, neighborcover_mapreduce, isclique
export generate_set, mirrors, mirrorcover, neighbors2

function neighborcover_mapreduce(func, red, eg::EliminateGraph, vi::Int)
    pre = func(vi)
    for vj in vertices(eg)
        if isconnected(eg,vj,vi)
            # find a neighbor cover
            pre = red(pre, func(vj))
        end
    end
    return pre
end

function isclique(eg::EliminateGraph, vs)
    for vj in vs
        for vi in vs
            vi!=vj && !isconnected(eg, vi, vj) && return false
        end
    end
    return true
end

isclique(eg::EliminateGraph) = isclique(eg, vertices(eg))

"""
    generate_set(eg::EliminateGraph, set::AbstractVertexSet) -> Vector

Generate (allocate) the set of vertices.
"""
function generate_set end

# nearest neighbors
@inline function generate_set(eg::EliminateGraph, nn::NearestNeighbors{OPEN})
    return filter(j->isconnected(eg,j,nn.i), vertices(eg))
end

# 2nd nearest neighbors, nbs can be either neighbors or neighbor cover
@inline function generate_set(eg::EliminateGraph, nnn::Neighbors{OPEN,2}, nbs)
    return filter(j->j!=nnn.i && !isconnected(eg,j,nnn.i) && any(nb->isconnected(eg,j,nb), nbs), vertices(eg))
end

@inline function generate_set(eg::EliminateGraph, nnn::Neighbors{CLOSED,2}, nbs)
    return filter(j->j in nbs || any(nb->isconnected(eg,j,nb), nbs), vertices(eg))
end
generate_set(eg::EliminateGraph, nnn::Neighbors{SP,2} where SP) = generate_set(eg,nnn,generate_set(eg,Neighbors{OPEN,1}(nnn.i)))

# nearest neighbors + itself
@inline function generate_set(eg::EliminateGraph, nn::NearestNeighbors{CLOSED})
    return filter(vj->isconnected(eg,vj,nn.i) || nn.i==vj, vertices(eg))
end

# mirrors, including itself
function generate_set(eg::EliminateGraph, set::Mirrors{CLOSED}, nc1, nbs2)
    push!(generate_set(eg, Mirrors{OPEN}(set.i), nc1, nbs2), set.i)
end

function generate_set(eg::EliminateGraph, set::Mirrors{CLOSED})
    nc1 = generate_set(eg, NeighborCover(set.i))
    nbs2 = generate_set(eg, Neighbors{OPEN, 2}(set.i), nc1)
    generate_set(eg, set, nc1, nbs2)
end

# mirrors
function generate_set(eg::EliminateGraph, set::Mirrors{OPEN}, nc1, nbs2)
    filter(v->isclique(eg, setdiff(nc1,neighbors(eg,v))), nbs2)
end

function generate_set(eg::EliminateGraph, set::Mirrors{OPEN})
    nc1 = generate_set(eg, NeighborCover(set.i))
    generate_set(eg, set, nc1, generate_set(eg, Neighbors{OPEN,2}(set.i), nc1))
end

function generate_set(eg::EliminateGraph, set::Vertex)
    [set.i]
end

function generate_set(eg::EliminateGraph, set::UnionOf)
    generate_set(eg, set.A) ∪ generate_set(eg, set.B)
end

########## Short cuts #############
"""
    neighbors2(eg::EliminateGraph, i::Int)

Get 2nd nearest neighbors, i.e. distance 2 vertices.
"""
neighbors2(eg::EliminateGraph, i::Int) = generate_set(eg,Neighbors{OPEN,2}(i))

"""
    mirrors(eg::EliminateGraph, vi::Int)

Get mirrors of vertex `vi`.
"""
mirrors(eg::EliminateGraph, vi::Int) = generate_set(eg, Mirrors{OPEN}(vi))

"""
    mirrorcover(eg::EliminateGraph, vi::Int)

Get mirrors of vertex `vi`, as well as itself.
"""
mirrorcover(eg::EliminateGraph, vi::Int) = generate_set(eg, Mirrors{CLOSED}(vi))
