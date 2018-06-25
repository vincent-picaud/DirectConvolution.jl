module DirectConvolution

const RootDir = dirname(dirname(Base.functionloc(DirectConvolution.eval, Tuple{Void})[1]))

using StaticArrays

include("utils.jl")
include("linearFilter.jl")
include("directConvolution.jl")
include("SG_Filter.jl")
include("udwt.jl")

end # module
