using Documenter, DirectConvolution



makedocs(modules=[DirectConvolution],
	 format = :html,
	 sitename = "Package name",
	 doctest=true)


deploydocs(
    repo   = "github.com/vincent-picaud/DirectConvolution.jl.git",
    target = "build",
    deps   = nothing,
    make   = nothing
)
