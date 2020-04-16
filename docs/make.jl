using Documenter, EasyStream

makedocs(;
    modules=[EasyStream],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/Conradox/EasyStream.jl/blob/{commit}{path}#L{line}",
    sitename="EasyStream.jl",
    authors="Pedro Conrado",
    assets=String[],
)

deploydocs(;
    repo="github.com/Conradox/EasyStream.jl",
)
