using Documenter, EasyStream

makedocs(;
    modules=[EasyStream],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "Guide" => Any[
        "Getting Started" => "pages/guide.md"],
        "Manual" => Any[
        "pages/stream.md",
        "pages/measures.md",
        "pages/output.md",
        "pages/format.md",

        ],
        "Library" => "pages/library.md",
    #    "Library" => Any[
    #        "Public" => "lib/public.md"]
    ],
    repo="https://github.com/Conradox/EasyStream.jl/blob/{commit}{path}#L{line}",
    sitename="EasyStream.jl",
    authors="Pedro Conrado",
    assets=String[],
)

deploydocs(;
    repo="github.com/Conradox/EasyStream.jl",
)
