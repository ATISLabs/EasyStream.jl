using Documenter, EasyStream

makedocs(;
    modules=[EasyStream],
    format=Documenter.HTML(),
    pages=[
        "Introduction" => "index.md",
        "Stream" => "stream.md",
        "Modifiers" => "modifiers.md"
    ],
    repo="https://github.com/ATISLabs/EasyStream.jl/blob/{commit}{path}#L{line}",
    sitename="EasyStream.jl",
    authors="ATISLabs",
    assets=String[],
)

deploydocs(;
    repo="github.com/ATISLabs/EasyStream.jl",
)
