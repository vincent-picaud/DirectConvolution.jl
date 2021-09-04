using DirectConvolution
using Documenter

DocMeta.setdocmeta!(DirectConvolution, :DocTestSetup, :(using DirectConvolution); recursive=true)
doctest(DirectConvolution, fix=true)
