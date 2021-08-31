```@meta
CurrentModule = DirectConvolution
```

# DirectConvolution

Documentation for [DirectConvolution](https://github.com/vincent-picaud/DirectConvolution.jl).

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
## Automatically generated 

```@index
```

