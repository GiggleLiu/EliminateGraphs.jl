# EliminateGraphs

[![Build Status](https://travis-ci.com/GiggleLiu/EliminateGraphs.jl.svg?branch=master)](https://travis-ci.com/GiggleLiu/EliminateGraphs.jl)
[![Codecov](https://codecov.io/gh/GiggleLiu/EliminateGraphs.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/GiggleLiu/EliminateGraphs.jl)

Maximum independent set algorithms, e.g. branching, measure and conquer.

## To develop
Type `]` in a Julia REPL, then input
```julia
pkg> dev git@github.com:GiggleLiu/EliminateGraphs.jl.git
```

## To run an example
```julia
julia> using EliminateGraphs

julia> eg = rand_eg(60, 0.05);

julia> mis1(eg)  # naive branching algorithm with O(3^(n/3)) complexity.
julia> mis1(eg)  # sophisticated branching algorithm with O(1.2852^N) complexity.
```

Using `EliminateGraph`,

```julia
julia> p = K_eg(3,3)
EliminateGraph
  0  0  0  1  1  1
  0  0  0  1  1  1
  0  0  0  1  1  1
  1  1  1  0  0  0
  1  1  1  0  0  0
  1  1  1  0  0  0

julia> q = p \ Neighbors{CLOSED, 1}(3)
EliminateGraph
  0  0  ⋅  ⋅  ⋅  ⋅
  0  0  ⋅  ⋅  ⋅  ⋅
  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅
  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅
  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅
  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅

julia> nv(q), ne(q)
(2, 0)

julia> vertices(q)
2-element VertexIter{EliminateGraph}:
 1
 2

julia> neighbors(p, 3)
NeighborIter{OPEN,1,EliminateGraph}
(4, 5, 6)
```

## References
* [Exact Exponential Algorithms](http://www.ii.uib.no/~fomin/BookEA/BookEA.pdf)
