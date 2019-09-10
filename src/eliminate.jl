export eliminate, eliminate!, recover!

"""
    eliminate!(eg::EliminateGraph, vertices)

Eliminate vertices from a graph.
"""
function eliminate!(eg::EliminateGraph, vi::Int)
    N = nv0(eg)
    @inbounds iptr = eg.level == 0 ? 0 : eg.ptr[eg.level]
    for j in N-eg.nv+1:N
        @inbounds vj = eg.vertices[j]
        if vj==vi
            iptr += 1
            eg.level += 1
            @inbounds eg.ptr[eg.level] = iptr
            unsafe_swap!(eg.vertices, j, iptr)
            break
        end
    end
    eg.nv -= 1
    return eg
end

function eliminate!(eg::EliminateGraph, vs)
    N = nv0(eg)
    @inbounds iptr = eg.level == 0 ? 0 : eg.ptr[eg.level]
    for vi in vs
        for j in N-eg.nv+1:N
            @inbounds vj = eg.vertices[j]
            if vj==vi
                iptr += 1
                unsafe_swap!(eg.vertices, j, iptr)
                break
            end
        end
    end
    eg.level += 1
    eg.nv -= length(vs)
    @inbounds eg.ptr[eg.level] = iptr
    return eg
end

# the fallback
function eliminate!(eg::EliminateGraph, nc::AbstractVertexSet)
    eliminate!(eg, generate_set(eg, nc))
end

"""
    eliminate([func], eg::EliminateGraph, vertices)
    eg \\ vertices

Eliminate vertices from a graph, return the value of `func(eliminated_graph)` if `func` provided.
"""
eliminate(eg, vertices) = eliminate!(copy(eg), vertices)

@inline function eliminate(func, eg::EliminateGraph, vi)
    eliminate!(eg, vi)
    res = func(eg)
    recover!(eg)
    return res
end

Base.:\(eg::EliminateGraph, vertices) = eliminate(eg, vertices)

"""restore eliminated vertices for a level (one call of elimintion function)."""
function recover!(eg::EliminateGraph)
    @inbounds eg.nv += eg.ptr[eg.level] - (eg.level==1 ? 0 : eg.ptr[eg.level-1])
    eg.level -= 1
    eg
end

##################### Specialized ######################
@generated function eliminate!(eg::EliminateGraph, nc::Neighbors{SP,1}) where SP
    condition = SP == CLOSED ? :(vi == nc.i || isconnected(eg, vi, nc.i)) : :(isconnected(eg, vi, nc.i))
    quote
        @inbounds iptr = eg.level == 0 ? 0 : eg.ptr[eg.level]
        for i in nv0(eg)-eg.nv+1:nv0(eg)
            @inbounds vi = eg.vertices[i]
            $condition || continue
            iptr += 1
            eg.nv -= 1
            unsafe_swap!(eg.vertices, i, iptr)
        end
        eg.level += 1
        @inbounds eg.ptr[eg.level] = iptr
        return eg
    end
end

function eliminate!(eg::EliminateGraph, set::Mirrors{CLOSED})
    nc1 = generate_set(eg, NeighborCover(set.i))

    @inbounds iptr = eg.level == 0 ? 0 : eg.ptr[eg.level]
    for i in nv0(eg)-eg.nv+1:nv0(eg)
        @inbounds vi = eg.vertices[i]
        vi == set.i || ((!isconnected(eg,vi,set.i) && any(nb->isconnected(eg,vi,nb), nc1)) && isclique(eg, setdiff(nc1,neighbors(eg,vi)))) || continue
        iptr += 1
        eg.nv -= 1
        unsafe_swap!(eg.vertices, i, iptr)
    end
    eg.level += 1
    @inbounds eg.ptr[eg.level] = iptr
    return eg
end

function eliminate!(eg::EliminateGraph, set::Mirrors{OPEN}) # can not generated since any is not pure
    nc1 = generate_set(eg, NeighborCover(set.i))

    @inbounds iptr = eg.level == 0 ? 0 : eg.ptr[eg.level]
    for i in nv0(eg)-eg.nv+1:nv0(eg)
        @inbounds vi = eg.vertices[i]
        (vi!=set.i && !isconnected(eg,vi,set.i) && any(nb->isconnected(eg,vi,nb), nc1)) && isclique(eg, setdiff(nc1,neighbors(eg,vi))) || continue
        iptr += 1
        eg.nv -= 1
        unsafe_swap!(eg.vertices, i, iptr)
    end
    eg.level += 1
    @inbounds eg.ptr[eg.level] = iptr
    return eg
end

@generated function eliminate!(eg::EliminateGraph, nc::UnionOf)
    if nc <: UnionOf{Neighbors{SP,1}, Neighbors{SP,1}} where SP
        SP = nc.parameters[1].parameters[1]
        condition = SP == CLOSED ? :(vi == nc.A.i || vi == nc.B.i || isconnected(eg, vi, nc.A.i) ||
            isconnected(eg, vi, nc.B.i)) : :(isconnected(eg, vi, nc.A.i) || isconnected(eg, vi, nc.B.i))
    elseif nc <: UnionOf{Neighbors{SP,1}, UnionOf{Neighbors{SP,1},Vertex}} where SP
        SP = nc.parameters[1].parameters[1]
        condition = SP == CLOSED ? :(vi == nc.A.i || vi == nc.B.A.i || vi == nc.B.B.i || isconnected(eg, vi, nc.A.i) ||
            isconnected(eg, vi, nc.B.A.i)) : :(vi == nc.B.B.i || isconnected(eg, vi, nc.A.i) || isconnected(eg, vi, nc.B.A.i))
    else
        return :(invoke(eliminate!, Tuple{EliminateGraph,AbstractVertexSet}, eg, nc))
    end

    quote
        @inbounds iptr = eg.level == 0 ? 0 : eg.ptr[eg.level]
        for i in nv0(eg)-eg.nv+1:nv0(eg)
            @inbounds vi = eg.vertices[i]
            $condition || continue
            iptr += 1
            eg.nv -= 1
            unsafe_swap!(eg.vertices, i, iptr)
        end
        eg.level += 1
        @inbounds eg.ptr[eg.level] = iptr
        return eg
    end
end
