using Documenter, EasyStream

makedocs(;
    modules=[EasyStream],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/ATISLabs/EasyStream.jl/blob/{commit}{path}#L{line}",
    sitename="EasyStream.jl",
    authors="ATISLabs",
    assets=String[],
)

deploydocs(;
    repo="github.com/ATISLabs/EasyStream.jl",
)
