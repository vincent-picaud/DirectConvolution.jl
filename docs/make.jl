using Documenter, DirectConvolution



makedocs(modules=[DirectConvolution],
	 format = :html,
	 sitename = "Package name",
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
    julia = "nightly", 
    deps   = nothing,
    make   = nothing
)
