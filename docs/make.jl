using Documenter, DirectConvolution



makedocs(modules=[DirectConvolution],
	 format = :html,
	 sitename = "DirectConvolution",
	 doctest=true,
         pages = Any[
             "Home" => "index.md",
             "Demos" => "demos.md",
             "Benchmarks" => "benchmarks.md"
         ]
         )


deploydocs(
    repo   = "github.com/vincent-picaud/DirectConvolution.jl.git",
    target = "build",
    julia = "0.6",
    deps   = nothing,
    make   = nothing
)
