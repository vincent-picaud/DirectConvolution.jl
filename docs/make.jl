using DirectConvolution
using Documenter

DocMeta.setdocmeta!(DirectConvolution, :DocTestSetup, :(using DirectConvolution); recursive=true)

makedocs(modules=[DirectConvolution],
         doctest = false,
         authors="vincent-picaud <picaud.vincent@gmail.com> and contributors",
         repo="https://github.com/vincent-picaud/DirectConvolution.jl/blob/{commit}{path}#{line}",
         sitename="DirectConvolution.jl",
         format=Documenter.HTML(;
                                prettyurls=get(ENV, "CI", "false") == "true",
                                canonical="https://vincent-picaud.github.io/DirectConvolution.jl",
                                assets=String[],
                                ),
         pages=[
             "Home" => "index.md",
         ],
         )

deploydocs(
    repo="github.com/vincent-picaud/DirectConvolution.jl.git",
    devbranch = "main"
)

