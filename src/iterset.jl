export VertexIter, EliminatedVertexIter, eliminated_vertices, iseliminated
export NeighborIter

"""
    VertexIter{GT}<:AbstractArray{Int,1}

Vertex enumerator for a graph.
"""
struct VertexIter{GT}<:AbstractArray{Int,1}
    eg::GT
end
Base.length(vs::VertexIter) = vs.eg.nv
Base.getindex(vs::VertexIter, i::Int) = vs.eg.vertices[end-vs.eg.nv+i]

"""
    EliminatedVertexIter{GT}<:AbstractArray{Int,1}

Eliminated vertex enumerator for a graph.
"""
struct EliminatedVertexIter{GT}<:AbstractArray{Int,1}
    eg::GT
end
Base.length(vs::EliminatedVertexIter) = nv0(vs.eg)-vs.eg.nv
Base.getindex(vs::EliminatedVertexIter, i::Int) = vs.eg.vertices[i]

"""eliminated vertices of a `EliminateGraph`."""
eliminated_vertices(eg::EliminateGraph) = EliminatedVertexIter(eg)

"""
    iseliminated(eg::EliminateGraph, i::Int) -> Bool

Return true if a vertex of a `EliminateGraph` is eliminated.
"""
iseliminated(eg::EliminateGraph, i::Int) = i in eliminated_vertices(eg)

for V in [:VertexIter, :EliminatedVertexIter]
    @eval Base.size(vs::$V) = (length(vs),)
    @eval Base.size(vs::$V, i::Int) = i==1 ? length(vs) : 1
    @eval Base.IteratorEltype(::Type{$V}) = Base.HasEltype()
    @eval Base.IteratorSize(::Type{$V}) = Base.HasLength()
    @eval Base.eltype(vs::$V) = Int
    @eval Base.eltype(vs::Type{$V}) = Int

    VI = V==:VertexIter ? :(eg.vertices[end-eg.nv+state]) : :(eg.vertices[state])
    @eval function Base.iterate(vs::$V, state=1)
        eg = vs.eg
        if state > length(vs)
            return nothing
        else
            @inbounds vi = $VI
            return vi, state+1
        end
    end
end

"""vertices of a graph."""
vertices(eg::EliminateGraph) = VertexIter(eg)

"""
    NeighborIter{SP,NTH,GT}<:AbstractArray{Int,1}

Neighbor enumerator for a graph.
"""
struct NeighborIter{SP,NTH,GT}
    eg::GT
    i::Int
end

NeighborIter{SP,NTH}(eg::GT, i::Int) where {SP,NTH,GT} = NeighborIter{SP,NTH,GT}(eg, i)

Base.IteratorEltype(::Type{NeighborIter}) = Base.HasEltype()
Base.eltype(vs::NeighborIter) = Int
Base.eltype(vs::Type{NeighborIter}) = Int

Base.:(==)(ni::NeighborIter, v) = Set([ni...]) == Set([v...])
Base.:(==)(v, ni::NeighborIter) = Set([v...]) == Set([nj...])
Base.:(==)(ni::NeighborIter, nj::NeighborIter) = Set([ni...]) == Set([nj...])

function Base.show(io::IO, ni::NeighborIter)
    println(io, summary(ni))
    print(io, (ni...,))
end

@generated function Base.iterate(ni::NeighborIter{SP,1}, state=1) where SP
    condition = SP == CLOSED ? :(vj==ni.i || isconnected(eg,vj,ni.i)) : :(isconnected(eg,vj,ni.i))
    quote
        eg = ni.eg
        if state > nv(eg)
            return nothing
        end
        for j = state:nv(eg)
            vj = @inbounds vertices(eg)[j]
            $condition && return (vj, j+1)
        end
        return nothing
    end
end

#neighbors(eg::EliminateGraph, i::Int) = generate_set(eg, NearestNeighbors{OPEN}(i))
neighbors(eg::EliminateGraph, vi::Int) = NeighborIter{OPEN,1}(eg, vi)

#neighborcover(eg::EliminateGraph, i::Int) = generate_set(eg, NearestNeighbors{CLOSED}(i))
neighborcover(eg::EliminateGraph, vi::Int) = NeighborIter{CLOSED,1}(eg, vi)
