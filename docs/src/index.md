# Direct Convolution

For small kernels this approach is more efficient than FFT

```math
\gamma[k]=\sum\limits_{i\in\Omega^\alpha}\alpha[i]\beta[k+\lambda i],\text{ with }\lambda\in\mathbb{Z}^*
``` 

This can be visualized as follow 

![](figures/a_offset.png)

Package aimes:
 - versatility: supports "à trous" algorithm, cross-correlation,
   different boundary extensions
 - performance: competitive compared to FFT approach for small kernels
 - implements: basic filtering operations like Savitzky-Golay filters
   or the decimated/undecimated wavelet transform.

This package basically exports two main functions 
 - `direcConv` computes the convolution and returns a newly allocated vector
 - `direcConv!` computes the convolution in-place

The introduced parameters and their roles is quickly describe below




## Basic usage examples

### Performance 

Typically wavelet transform involve small filters, of size 5 for
instance. We want to compare `directConv` to native Julia `conv`
function.

First one must check that the two methods return the same result. Note
that `conv` function return a vector γ of length |α|+|β|-1 whereas our
function respect initial β bounds, hence the returned γ vector has
same size as input β.

```@example
using DirectConvolution
α=rand(5);
β=rand(1000);
r1=conv(α,β);
r2=directConv(α,0,-1,β,ZeroPaddingBE,ZeroPaddingBE);
println("Result comparison $(r1[1:1000] ≈ r2)")
println("Julia conv()")
@time conv(α,β);
println("This directConv()")
@time directConv(α,0,-1,β,ZeroPaddingBE,ZeroPaddingBE);
```

### `α_offset` parameter
Let's start with a basic example, with zero padding boundary
extensions. This example shows the role of the `α_offset` parameter.

```@example
using DirectConvolution
α=Float64[0,1,0];
β=collect(Float64,1:6);
γ1=directConv(α,0,-1,β,ZeroPaddingBE,ZeroPaddingBE); # α_offset = 0
γ2=directConv(α,1,-1,β,ZeroPaddingBE,ZeroPaddingBE); # α_offset = 1
println("Filter coefficients") # hide
println("α = $(α)") # hide
println("Computation with α_offset=0 (observe the signal shift)") # hide
println("β  = $(β)") # hide
println("γ1 = $(γ1)") # hide
println("Computation with α_offset=1 (observe the phase is corrected)") # hide
println("β  = $(β)") # hide
println("γ2 = $(γ2)") # hide
```

### Filters

Plot test

```@eval 
using Plots
maldi_data = readcsv("../data/Maldi_ToF.txt")
plot(maldi_data[:,1], maldi_data[:,2], grid=false)
savefig("figures/plot.png")

nothing
```

![](figures/plot.png)


**CAVEAT**: under construction

## Undecimated Wavelet Transform

```@example
using DirectConvolution
using Plots
signal=readcsv("../data/Maldi_ToF.txt");
signal=signal[:,2];

filter = UDWT_Filter_Starck2{Float64}()
m = udwt(signal,filter,scale=8)
label=["W$i" for i in 1:scale(m)];
plot(m.W,label=reshape(label,1,scale(m)))
plot!(m.V,label="V$(scale(m))");
plot!(signal,label="signal");
savefig("./figures/udwt.png")
```

![](./figures/udwt.png)

### Filters

```@docs
DirectConvolution.UDWT_Filter_Biorthogonal
```

```@docs
DirectConvolution.UDWT_Filter
```

### UDWT (transform)


```@docs
udwt
```

```@docs
udwt!
```


```@docs
inverse_udwt
```

```@docs
inverse_udwt!
```

### UDWT adjoint operator (todo)

### Example

### Filtering, iterative reconstruction... (todo)

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
