export mis1, mis1e

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

"""
    mis1e(eg::EliminateGraph)

Enumerate all MISs of a graph. Returns the size of the MIS and the MISs.
"""
function mis1e(eg::EliminateGraph)
    N = nv(eg)
    if N == 0
        return 0, push!(Set{Set{Int}}(), Set{Int}())
    else
        vmin, dmin = mindegree_vertex(eg)
        alpha =  typemin(Int)
        sets = Set{Set{Int}}()
        for v in neighborcover(eg, vmin)
            subgraph = eliminate(eg, NeighborCover(v))
            alphav, setsv = mis1e(subgraph)
            if alphav > alpha
                alpha = alphav
                empty!(sets)
            end
            if alphav == alpha
                for s in setsv
                    push!(s, v)
                    push!(sets, s)
                end
            end
        end
        return 1 + alpha, sets
    end
end
