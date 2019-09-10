using Documenter, EliminateGraphs

makedocs(;
    modules=[EliminateGraphs],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/GiggleLiu/EliminateGraphs.jl/blob/{commit}{path}#L{line}",
    sitename="EliminateGraphs.jl",
    authors="JinGuo Liu, WenJie Peng",
    assets=String[],
)

deploydocs(;
    repo="github.com/GiggleLiu/EliminateGraphs.jl",
)
