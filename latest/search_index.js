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
    "text": "Typically wavelet transform involve small filters, of size 5 for instance. We want to compare directConv to native Julia conv function.First one must check that the two methods return the same result. Note that conv function return a vector γ of length |α|+|β|-1 whereas our function respect initial β bounds, hence the returned γ vector has same size as input β.using DirectConvolution\nα=rand(5);\nβ=rand(1000);\nr1=conv(α,β);\nr2=directConv(α,0,-1,β,:ZeroPadding,:ZeroPadding);\nprintln(\"Result comparison $(r1[1:1000] ≈ r2)\")\nprintln(\"Julia conv()\")\n@time conv(α,β);\nprintln(\"This directConv()\")\n@time directConv(α,0,-1,β,:ZeroPadding,:ZeroPadding);"
},

{
    "location": "index.html#α_offset-parameter-1",
    "page": "Home",
    "title": "α_offset parameter",
    "category": "section",
    "text": "Let\'s start with a basic example, with zero padding boundary extensions. This example shows the role of the α_offset parameter.using DirectConvolution\nα=Float64[0,1,0];\nβ=collect(Float64,1:6);\nγ1=directConv(α,0,-1,β,:ZeroPadding,:ZeroPadding); # α_offset = 0\nγ2=directConv(α,1,-1,β,:ZeroPadding,:ZeroPadding); # α_offset = 1\nprintln(\"Filter coefficients\") # hide\nprintln(\"α = $(α)\") # hide\nprintln(\"Computation with α_offset=0 (observe the signal shift)\") # hide\nprintln(\"β  = $(β)\") # hide\nprintln(\"γ1 = $(γ1)\") # hide\nprintln(\"Computation with α_offset=1 (observe the phase is corrected)\") # hide\nprintln(\"β  = $(β)\") # hide\nprintln(\"γ2 = $(γ2)\") # hide"
},

{
    "location": "index.html#Filters-1",
    "page": "Home",
    "title": "Filters",
    "category": "section",
    "text": "Plot testusing Plots\nmaldi_data = readcsv(\"../data/Maldi_ToF.txt\")\nplot(maldi_data[:,1], maldi_data[:,2], grid=false)\nsavefig(\"figures/plot.png\")\n\nnothing(Image: )CAVEAT: under construction"
},

{
    "location": "index.html#Demos-1",
    "page": "Home",
    "title": "Demos",
    "category": "section",
    "text": "Pages = [\n    \"demos.md\"]\nDepth = 1"
},

{
    "location": "index.html#DirectConvolution.SG_Filter",
    "page": "Home",
    "title": "DirectConvolution.SG_Filter",
    "category": "Function",
    "text": "SG_Filter(;halfWidth::Int=5,degree=2,T::Type=Float64)::Array{T,2}\n\nReturns Savitzky-Golay filter matrix.\n\nfilter length is 2*halfWidth+1\npolynomial degree is degree\n\n\n\n"
},

{
    "location": "index.html#DirectConvolution.directConv-Union{Tuple{AbstractArray{T,1},Int64,Int64,AbstractArray{T,1},Symbol,Symbol}, Tuple{T}} where T",
    "page": "Home",
    "title": "DirectConvolution.directConv",
    "category": "Method",
    "text": "directConv(tilde_α::AbstractArray{T,1},\n            α_offset::Int64,\n            λ::Int64,\n\n            β::AbstractArray{T,1},\n\n            LeftBoundary::Symbol,\n            RightBoundary::Symbol)\n\nCompute convolution.\n\nReturn γ, a created vector of length identical to β one.\n\n\n\n"
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
