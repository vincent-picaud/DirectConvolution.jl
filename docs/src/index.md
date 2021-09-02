```@meta
CurrentModule = DirectConvolution
```

# DirectConvolution

Documentation for [DirectConvolution](https://github.com/vincent-picaud/DirectConvolution.jl).
  
```@setup session_1
using DirectConvolution
using DelimitedFiles
```

# Use cases

These demos use data stored in the `data/` folder.

```@repl session_1
data_1D=readdlm(joinpath(pwd(),"..","..","data/signal_1.csv"),',')
```

Plot test
```@repl session_1
using PyPlot

plot(data_1D[:,1],data_1D[:,2])

savefig("plot.svg")
```

![test fig](plot.svg)

## Savitzky-Golay filters

Savitzky-Golay filters are a common approach to compute smoothed
derivatives of a signal.

Creates a set of Savitzky-Golay filters using polynomial of degree $3$
with a window width of $11=2\times 5+1$.


```@repl session_1
sg = SG_Filter(Float64,halfWidth=5,degree=3);
```

This can be checked with 

```@repl session_1
length(sg)
polynomialOrder(sg)
```

# API


```@index
```

```@docs
scale
```

## Linear Filters
```@docs
LinearFilter
```

The following functions are related to linear filters:
```@docs
fcoef
```

```@docs
DirectConvolution.length
```
TODO: explain with an example

```@docs
offset
```

```@docs
range
```

### Available Linear Filters

```@docs
LinearFilter_Default
```

## Convolution procedure

### Boundary extension


There are several possible boundary extension:

```@docs
ZeroPaddingBE
```

```@docs
ConstantBE
```

```@docs
PeriodicBE
```

```@docs
MirrorBE
```

Contrary to other common library (TODO: give some examples) you have
no restriction concerning domains.

```@docs
boundaryExtension
```

### Computational function

```@docs
directConv!
```

