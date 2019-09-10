export degrees, degree, mindegree_vertex, maxdegree_vertex, minmaxdegree_vertex

"""Get degrees of all vertices in a graph."""
degrees(eg::EliminateGraph) = degree.(Ref(eg), vertices(eg))

"""
    neighbors(eg::EliminateGraph, i::Int)

Get degree of vertex `i`.
"""
@inline function degree(eg::EliminateGraph, vi::Int)
    sum(vj->isconnected(eg,vi,vj), vertices(eg))
end

"""find `(vertex, degree)` with minimum degree of a graph."""
function mindegree_vertex(eg::EliminateGraph)
    N = nv(eg)
    dmin = 999999
    vmin = 0
    for vj in vertices(eg)
        dj = 0
        for vi in vertices(eg)
            dj += isconnected(eg,vi,vj)
        end
        if dj < dmin
            dmin = dj
            vmin = vj
        end
    end
    return vmin, dmin
end

"""find `(min_degree_vertex, max_degree_vertex, min_degree, max_degree)` of a graph."""
function minmaxdegree_vertex(eg::EliminateGraph)
    N = nv(eg)
    dmin = 999999
    dmax = 0
    vmin = 0
    vmax = 0
    for vj in vertices(eg)
        dj = 0
        for vi in vertices(eg)
            dj += isconnected(eg,vi,vj)
        end
        if dj < dmin
            dmin = dj
            vmin = vj
        end
        if dj > dmax
            dmax = dj
            vmax = vj
        end
    end
    return vmin, vmax, dmin, dmax
end

"""find `(vertex, degree)` with maximum degree of a graph."""
function maxdegree_vertex(eg::EliminateGraph)
    N = nv(eg)
    dmax = 0
    vmax = 0
    for vj in vertices(eg)
        dj = 0
        for vi in vertices(eg)
            dj += isconnected(eg,vi,vj)
        end
        if dj > dmax
            dmax = dj
            vmax = vj
        end
    end
    return vmax, dmax
end
