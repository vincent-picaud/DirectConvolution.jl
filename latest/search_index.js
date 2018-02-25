var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Direct-Convolution-1",
    "page": "Home",
    "title": "Direct Convolution",
    "category": "section",
    "text": "For small kernels this approach is more efficient than FFTgammak=sumlimits_iinOmega^alphaalphaibetak+lambda itext with lambdainmathbbZ^*This can be visualized as follow (Image: )Package aimes:versatility: supports \"à trous\" algorithm, cross-correlation, different boundary extensions\nperformance: competitive compared to FFT approach for small kernels\nimplements: basic filtering operations like Savitzky-Golay filters or the decimated/undecimated wavelet transform.This package basically exports two main functions direcConv computes the convolution and returns a newly allocated vector\ndirecConv! computes the convolution in-placeThe introduced parameters and their roles is quickly describe below"
},

{
    "location": "index.html#Basic-usage-examples-1",
    "page": "Home",
    "title": "Basic usage examples",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Performance-1",
    "page": "Home",
    "title": "Performance",
    "category": "section",
    "text": "Typically wavelet transform involve small filters, of size 5 for instance. We want to compare directConv to native Julia conv function.First one must check that the two methods return the same result. Note that conv function return a vector γ of length |α|+|β|-1 whereas our function respect initial β bounds, hence the returned γ vector has same size as input β.using DirectConvolution\nα=rand(5);\nβ=rand(1000);\nr1=conv(α,β);\nr2=directConv(α,0,-1,β,ZeroPaddingBE,ZeroPaddingBE);\nprintln(\"Result comparison $(r1[1:1000] ≈ r2)\")\nprintln(\"Julia conv()\")\n@time conv(α,β);\nprintln(\"This directConv()\")\n@time directConv(α,0,-1,β,ZeroPaddingBE,ZeroPaddingBE);"
},

{
    "location": "index.html#α_offset-parameter-1",
    "page": "Home",
    "title": "α_offset parameter",
    "category": "section",
    "text": "Let\'s start with a basic example, with zero padding boundary extensions. This example shows the role of the α_offset parameter.using DirectConvolution\nα=Float64[0,1,0];\nβ=collect(Float64,1:6);\nγ1=directConv(α,0,-1,β,ZeroPaddingBE,ZeroPaddingBE); # α_offset = 0\nγ2=directConv(α,1,-1,β,ZeroPaddingBE,ZeroPaddingBE); # α_offset = 1\nprintln(\"Filter coefficients\") # hide\nprintln(\"α = $(α)\") # hide\nprintln(\"Computation with α_offset=0 (observe the signal shift)\") # hide\nprintln(\"β  = $(β)\") # hide\nprintln(\"γ1 = $(γ1)\") # hide\nprintln(\"Computation with α_offset=1 (observe the phase is corrected)\") # hide\nprintln(\"β  = $(β)\") # hide\nprintln(\"γ2 = $(γ2)\") # hide"
},

{
    "location": "index.html#Filters-1",
    "page": "Home",
    "title": "Filters",
    "category": "section",
    "text": "Plot testusing Plots\nmaldi_data = readcsv(\"../data/Maldi_ToF.txt\")\nplot(maldi_data[:,1], maldi_data[:,2], grid=false)\nsavefig(\"figures/plot.png\")\n\nnothing(Image: )CAVEAT: under construction"
},

{
    "location": "index.html#Undecimated-Wavelet-Transform-1",
    "page": "Home",
    "title": "Undecimated Wavelet Transform",
    "category": "section",
    "text": "using DirectConvolution\nusing Plots\nsignal=readcsv(\"../data/Maldi_ToF.txt\");\nsignal=signal[:,2];\n\nfilter = UDWT_Filter_Starck2{Float64}()\nm = udwt(signal,filter,scale=8)\nlabel=[\"W$i\" for i in 1:scale(m)];\nplot(m.W,label=reshape(label,1,scale(m)))\nplot!(m.V,label=\"V$(scale(m))\");\nplot!(signal,label=\"signal\");\nsavefig(\"./figures/udwt.png\")(Image: )"
},

{
    "location": "index.html#DirectConvolution.UDWT_Filter_Biorthogonal",
    "page": "Home",
    "title": "DirectConvolution.UDWT_Filter_Biorthogonal",
    "category": "Type",
    "text": " abstract type UDWT_Filter_Biorthogonal{T<:Number}\n\nAbstract type defining the phi, psi, tildephi and tildepsi filters associated to an undecimated biorthogonal wavelet transform\n\nGeneric methods are:\n\nphi: ϕ_filter(c::UDWT_Filter_Biorthogonal)\nphi support: ϕ_offset(c::UDWT_Filter_Biorthogonal)\npsi: ψ_filter(c::UDWT_Filter_Biorthogonal)\npsi support: ψ_offset(c::UDWT_Filter_Biorthogonal)\n\n\n\n"
},

{
    "location": "index.html#DirectConvolution.UDWT_Filter",
    "page": "Home",
    "title": "DirectConvolution.UDWT_Filter",
    "category": "Type",
    "text": " abstract type UDWT_Filter{T<:Number} <: UDWT_Filter_Biorthogonal{T}\n\nSpecialization of UDWT_Filter_Biorthogonal to orthogonal filters\n\nFor these filters, we have:\n\ntildeϕ_filter(c::UDWT_Filter)=ϕ_filter(c)\ntildeψ_filter(c::UDWT_Filter)=ψ_filter(c)\ntildeϕ_offset(c::UDWT_Filter)=ϕ_offset(c)\ntildeψ_offset(c::UDWT_Filter)=ψ_offset(c)\n\n\n\n"
},

{
    "location": "index.html#Filters-2",
    "page": "Home",
    "title": "Filters",
    "category": "section",
    "text": "DirectConvolution.UDWT_Filter_BiorthogonalDirectConvolution.UDWT_Filter"
},

{
    "location": "index.html#DirectConvolution.udwt",
    "page": "Home",
    "title": "DirectConvolution.udwt",
    "category": "Function",
    "text": "udwt(signal::AbstractArray{T,1},filter::UDWT_Filter_Biorthogonal{T};scale::Int=3) where {T<:Number}\n\nPerforms a 1D undecimated wavelet transform\n\n(mathcalW_j+1f)u=(barg_j*mathcalV_jf)u\n\n(mathcalV_j+1f)u=(barh_j*mathcalV_jf)u\n\n\n\n"
},

{
    "location": "index.html#DirectConvolution.inverse_udwt",
    "page": "Home",
    "title": "DirectConvolution.inverse_udwt",
    "category": "Function",
    "text": "inverse_udwt(udwt_domain::UDWT{T})::Array{T,1} where {T<:Number}\n\nPerforms an inverse 1D undecimated wavelet transform and returns a new vector containing the reconstructed signal.\n\n\n\n"
},

{
    "location": "index.html#DirectConvolution.inverse_udwt!",
    "page": "Home",
    "title": "DirectConvolution.inverse_udwt!",
    "category": "Function",
    "text": "inverse_udwt(udwt_domain::UDWT{T})::Array{T,1} where {T<:Number}\n\nPerforms an inverse 1D undecimated wavelet transform using a pre-allocated vector reconstructed_signal.\n\n\n\n"
},

{
    "location": "index.html#UDWT-(transform)-1",
    "page": "Home",
    "title": "UDWT (transform)",
    "category": "section",
    "text": "udwtudwt!inverse_udwtinverse_udwt!"
},

{
    "location": "index.html#UDWT-adjoint-operator-(todo)-1",
    "page": "Home",
    "title": "UDWT adjoint operator (todo)",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Example-1",
    "page": "Home",
    "title": "Example",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Filtering,-iterative-reconstruction...-(todo)-1",
    "page": "Home",
    "title": "Filtering, iterative reconstruction... (todo)",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Demos-1",
    "page": "Home",
    "title": "Demos",
    "category": "section",
    "text": "Pages = [\n    \"demos.md\"]\nDepth = 1"
},

{
    "location": "index.html#DirectConvolution.BoundaryExtension",
    "page": "Home",
    "title": "DirectConvolution.BoundaryExtension",
    "category": "Type",
    "text": " BoundaryExtension\n\nAvailable extenions are:\n\nstruct ZeroPaddingBE <: BoundaryExtension end\nstruct ConstantBE <: BoundaryExtension end\nstruct PeriodicBE <: BoundaryExtension end\nstruct MirrorBE <: BoundaryExtension end\n\n\n\n"
},

{
    "location": "index.html#DirectConvolution.SG_Filter",
    "page": "Home",
    "title": "DirectConvolution.SG_Filter",
    "category": "Function",
    "text": "SG_Filter(;halfWidth::Int=5,degree=2,T::Type=Float64)::Array{T,2}\n\nReturns Savitzky-Golay filter matrix.\n\nfilter length is 2*halfWidth+1\npolynomial degree is degree\n\n\n\n"
},

{
    "location": "index.html#DirectConvolution.directConv!-Union{Tuple{AbstractArray{T,1},Int64,Int64,AbstractArray{T,1},AbstractArray{T,1},UnitRange{Int64},Type{LeftBE},Type{RightBE}}, Tuple{AbstractArray{T,1},Int64,Int64,AbstractArray{T,1},AbstractArray{T,1},UnitRange{Int64},Type{LeftBE}}, Tuple{AbstractArray{T,1},Int64,Int64,AbstractArray{T,1},AbstractArray{T,1},UnitRange{Int64}}, Tuple{LeftBE}, Tuple{RightBE}, Tuple{T}} where RightBE<:DirectConvolution.BoundaryExtension where LeftBE<:DirectConvolution.BoundaryExtension where T<:Number",
    "page": "Home",
    "title": "DirectConvolution.directConv!",
    "category": "Method",
    "text": "     directConv!(tilde_α::AbstractArray{T,1},\n                 α_offset::Int,\n                 λ::Int,\n\n                 β::AbstractArray{T,1},\n\n                 γ::AbstractArray{T,1},\n                 Ωγ::UnitRange{Int},\n                 \n                 ::Type{LeftBE}=ZeroPaddingBE,\n                 ::Type{RightBE}=ZeroPaddingBE;\n                 \n                 accumulate::Bool=false) where {T <: Number,\n                                                LeftBE <: BoundaryExtension,\n                                                RightBE <: BoundaryExtension}\n\nComputes a convolution.\n\nInplace modification of γ\n\n\n\n"
},

{
    "location": "index.html#DirectConvolution.directConv-Union{Tuple{AbstractArray{T,1},Int64,Int64,AbstractArray{T,1},Type{LeftBE},Type{RightBE}}, Tuple{AbstractArray{T,1},Int64,Int64,AbstractArray{T,1},Type{LeftBE}}, Tuple{AbstractArray{T,1},Int64,Int64,AbstractArray{T,1}}, Tuple{LeftBE}, Tuple{RightBE}, Tuple{T}} where RightBE<:DirectConvolution.BoundaryExtension where LeftBE<:DirectConvolution.BoundaryExtension where T<:Number",
    "page": "Home",
    "title": "DirectConvolution.directConv",
    "category": "Method",
    "text": "    directConv(tilde_α::AbstractArray{T,1},\n                α_offset::Int64,\n                λ::Int64,\n\n                β::AbstractArray{T,1},\n\n                ::Type{LeftBE}=ZeroPaddingBE,\n                ::Type{RightBE}=ZeroPaddingBE) where {T <: Number,\n                                                      LeftBE <: BoundaryExtension,\n                                                      RightBE <: BoundaryExtension}\n\nComputes a convolution.\n\nReturns γ, a created vector of length identical to β one.\n\n\n\n"
},

{
    "location": "index.html#DirectConvolution.inverse_udwt!-Union{Tuple{DirectConvolution.UDWT{T},AbstractArray{T,1}}, Tuple{T}} where T<:Number",
    "page": "Home",
    "title": "DirectConvolution.inverse_udwt!",
    "category": "Method",
    "text": "inverse_udwt(udwt_domain::UDWT{T})::Array{T,1} where {T<:Number}\n\nPerforms an inverse 1D undecimated wavelet transform using a pre-allocated vector reconstructed_signal.\n\n\n\n"
},

{
    "location": "index.html#DirectConvolution.inverse_udwt-Union{Tuple{DirectConvolution.UDWT{T}}, Tuple{T}} where T<:Number",
    "page": "Home",
    "title": "DirectConvolution.inverse_udwt",
    "category": "Method",
    "text": "inverse_udwt(udwt_domain::UDWT{T})::Array{T,1} where {T<:Number}\n\nPerforms an inverse 1D undecimated wavelet transform and returns a new vector containing the reconstructed signal.\n\n\n\n"
},

{
    "location": "index.html#DirectConvolution.udwt-Union{Tuple{AbstractArray{T,1},DirectConvolution.UDWT_Filter_Biorthogonal{T}}, Tuple{T}} where T<:Number",
    "page": "Home",
    "title": "DirectConvolution.udwt",
    "category": "Method",
    "text": "udwt(signal::AbstractArray{T,1},filter::UDWT_Filter_Biorthogonal{T};scale::Int=3) where {T<:Number}\n\nPerforms a 1D undecimated wavelet transform\n\n(mathcalW_j+1f)u=(barg_j*mathcalV_jf)u\n\n(mathcalV_j+1f)u=(barh_j*mathcalV_jf)u\n\n\n\n"
},

{
    "location": "index.html#DirectConvolution.ϕ_filter-Tuple{DirectConvolution.UDWT_Filter_Biorthogonal}",
    "page": "Home",
    "title": "DirectConvolution.ϕ_filter",
    "category": "Method",
    "text": "See UDWT_Filter_Biorthogonal \n\n\n\n"
},

{
    "location": "index.html#Autodoc...-1",
    "page": "Home",
    "title": "Autodoc...",
    "category": "section",
    "text": "Modules = [DirectConvolution]\nOrder   = [:type, :function]"
},

{
    "location": "index.html#Benchmarks-1",
    "page": "Home",
    "title": "Benchmarks",
    "category": "section",
    "text": "Pages = [\n    \"benchmarks.md\"]"
},

{
    "location": "index.html#Index-1",
    "page": "Home",
    "title": "Index",
    "category": "section",
    "text": ""
},

{
    "location": "demos.html#",
    "page": "Demos",
    "title": "Demos",
    "category": "page",
    "text": ""
},

{
    "location": "demos.html#Demos-1",
    "page": "Demos",
    "title": "Demos",
    "category": "section",
    "text": "TODO -> SG filter, wavelets ?"
},

{
    "location": "benchmarks.html#",
    "page": "Benchmarks",
    "title": "Benchmarks",
    "category": "page",
    "text": ""
},

{
    "location": "benchmarks.html#Benchmarks-1",
    "page": "Benchmarks",
    "title": "Benchmarks",
    "category": "section",
    "text": "TODO -> compare FFT and directConvolution"
},

]}
