export rand_eg, empty_eg, chain_eg, ring_eg, K_eg, disconnected_cliques_eg
export petersen_graph, c60_graph, get_petersen_graph, get_c60_graph
export inverse_eg, smallworld_eg, random_regular_eg

"""
    K_eg(nv::Int, [nw]) -> EliminateGraph

fully connected graph, if `nw` provided, compute `K(nv,nw)` graph.
"""
K_eg(nv::Int) = rand_eg(nv, 1.0)
K_eg(m::Int, n::Int) = EliminateGraph(m+n,vcat([vi=>vj for vi=1:m, vj=m+1:m+n]...))

"""
Inverse graph, arXiv: 1807.03739
"""
function inverse_eg(n::Int)
    EliminateGraph(n, vcat([x=>mod1(x+1, n) for x=1:n], [x=>mod(-mod_inverse(x-1, n), n)+1 for x=2:n]))
end

"""

"""
function smallworld_eg(n::Int; ρ::Real)
    longlinks = Pair{Int,Int}[]
    for x=1:n, y=1:n
        if abs(mod(x-y, n)) > 1 && rand() < ρ
            push!(longlinks, x=>y)
        end
    end
    EliminateGraph(n, vcat([x=>mod(x, n)+1 for x=1:n], longlinks))
end

function random_regular_eg(nv::Int, nreg::Int)
    eg = empty_eg(nv)
    g = random_regular_graph(nv, nreg)
    for i in 1:nv
        for j=g.fadjlist[i]
            unsafe_connect!(eg,i,j)
        end
    end
    return eg
end

"""
    mod_inverse(x::Int, N::Int) -> Int
Return `y` that `(x*y)%N == 1`, notice the `(x*y)%N` operations in Z* forms a group and this is the definition of inverse.
"""
function mod_inverse(x::Int, N::Int)
    for i=1:N
        (x*i)%N == 1 && return i
    end
    throw(ArgumentError("Can not find the inverse, $x is probably not in Z*($N)!"))
end

"""
A graph consists of disconnected cliques.
"""
function disconnected_cliques_eg(nvs::Int...)
    N = sum(nvs)
    tbl = zeros(Bool, N, N)
    offset = 0
    for nv in nvs
        for j=offset+1:offset+nv
            for i=offset+1:offset+nv
                i!=j && (@inbounds tbl[i,j] = true)
            end
        end
        offset += nv
    end
    return EliminateGraph(tbl)
end

"""
    empty_eg(nv::Int) -> EliminateGraph

fully disconnected graph
"""
empty_eg(nv::Int) = EliminateGraph(zeros(Bool,nv,nv))

"""
    rand_eg(nv::Int, density::Real) -> EliminateGraph

Generate a random `EliminateGraph`.
"""
function rand_eg(nv::Int, density::Real)
    tbl = rand(nv, nv) .< density
    copyltu!(tbl)
    for i=1:nv
        tbl[i,i] = false
    end
    EliminateGraph(tbl)
end

"""chain graph"""
chain_eg(nv::Int) = EliminateGraph(nv,[vi=>vi+1 for vi=1:nv-1])

"""ring graph"""
ring_eg(nv::Int) = EliminateGraph(nv,[vi=>mod1(vi+1,nv) for vi=1:nv])

# Special Graphs
get_petersen_graph() = EliminateGraph(10,
                    [1=>2, 2=>3, 3=>4, 4=>5, 5=>1,
                    1=>6, 2=>7, 3=>8, 4=>9, 5=>10,
                    6=>8, 7=>9, 8=>10, 9=>1, 10=>2])
const petersen_graph = get_petersen_graph()

get_c60_graph() = EliminateGraph(60, [1=>10, 1=>41, 1=>59, 2=>12, 2=>42, 2=>60, 3=>6, 3=>
        43, 3=>57, 4=>8, 4=>44, 4=>58, 5=>13, 5=>56, 5=>
        57, 6=>10, 6=>31, 7=>14, 7=>56, 7=>58, 8=>12, 8=>
        32, 9=>23, 9=>53, 9=>59, 10=>15, 11=>24, 11=>53, 11=>
        60, 12=>16, 13=>14, 13=>25, 14=>26, 15=>27, 15=>
        49, 16=>28, 16=>50, 17=>18, 17=>19, 17=>54, 18=>
        20, 18=>55, 19=>23, 19=>41, 20=>24, 20=>42, 21=>
        31, 21=>33, 21=>57, 22=>32, 22=>34, 22=>58, 23=>
        24, 25=>35, 25=>43, 26=>36, 26=>44, 27=>51, 27=>
        59, 28=>52, 28=>60, 29=>33, 29=>34, 29=>56, 30=>
        51, 30=>52, 30=>53, 31=>47, 32=>48, 33=>45, 34=>
        46, 35=>36, 35=>37, 36=>38, 37=>39, 37=>49, 38=>
        40, 38=>50, 39=>40, 39=>51, 40=>52, 41=>47, 42=>
        48, 43=>49, 44=>50, 45=>46, 45=>54, 46=>55, 47=>
        54, 48=>55])
const c60_graph = get_c60_graph()
