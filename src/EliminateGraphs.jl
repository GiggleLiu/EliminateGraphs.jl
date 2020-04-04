module EliminateGraphs

using LightGraphs
import LightGraphs: vertices, edges, neighbors, ne, nv, degree

include("utils.jl")
include("Core.jl")
include("Graph.jl")
include("iterset.jl")
include("generateset.jl")
include("degrees.jl")
include("eliminate.jl")
include("graphlib.jl")
include("algorithms/algorithms.jl")
end # module
