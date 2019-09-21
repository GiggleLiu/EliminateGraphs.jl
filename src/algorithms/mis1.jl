export mis1

"""
Solving MIS problem with simple branching algorithm.
"""
function mis1(eg::EliminateGraph)
    N = nv(eg)
    if N == 0
        return 0
    else
        vmin, dmin = mindegree_vertex(eg)
        return 1 + neighborcover_mapreduce(y->eliminate(mis1, eg, NeighborCover(y)), max, eg, vmin)
    end
end

function mis1(eg::EliminateGraph, visulization::Bool)
    N = mis1(eg)
    if visulization == true
        g = SimpleGraph(N)
        gplot(g)
    end
end
