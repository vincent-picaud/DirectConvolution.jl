using DirectConvolution
using Test
using LinearAlgebra

@testset "DirectConvolution" begin

    include("utils.jl")

    include("linearFilter.jl")
    
    include("directConvolution.jl")

    include("SG_Filter.jl")

    include("udwt.jl")

end;
nothing
