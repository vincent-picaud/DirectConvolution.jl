# Direct Convolution

For small kernels this approach is more efficient than FFT

```math
\gamma[k]=\sum\limits_{i\in\Omega^\alpha}\alpha[i]\beta[k+\lambda i],\text{ with }\lambda\in\mathbb{Z}^*
``` 

This can be visualized as follow 

![](../figures/a_offset.png)

Package aimes:
 - versatility: supports "à trous" algorithm, cross-correlation,
   different boundary extensions
 - performance: beats FFT approach for small kernels
 - implements: basic filtering operations like Savitzky-Golay filters
   or the decimated/undecimated wavelet transform.
 
## Usage examples

Let's start with a basic example, with zero padding boundary
extension. This example shows the role of the `α_offset` parameter.

```@example
using DirectConvolution
α=Float64[0,1,0];
β=collect(Float64,1:6);
γ1=directConv(α,0,1,β,:ZeroPadding,:ZeroPadding); # α_offset = 0
γ2=directConv(α,1,1,β,:ZeroPadding,:ZeroPadding); # α_offset = 1
println("Filter coefficients") # hide
println("α = $(α)") # hide
println("Computation with α_offset=0 (observe the signal shift)") # hide
println("β  = $(β)") # hide
println("γ1 = $(γ1)") # hide
println("Computation with α_offset=1 (observe the phase is corrected)") # hide
println("β  = $(β)") # hide
println("γ2 = $(γ2)") # hide
```

## Comparison with FFT 

TODO

**CAVEAT**: under construction

## Demos

```@contents
Pages = [
    "demos.md"]
Depth = 1
```

## Autodoc...

```@autodocs
Modules = [DirectConvolution]
Order   = [:type, :function]
```


## Benchmarks

```@contents
Pages = [
    "benchmarks.md"]
```

## Index

```@index
```
