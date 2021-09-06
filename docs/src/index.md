```@meta
CurrentModule = DirectConvolution
```

# DirectConvolution

Documentation for [DirectConvolution](https://github.com/vincent-picaud/DirectConvolution.jl).

```@setup session_1
using DirectConvolution
using DelimitedFiles
using Plots
gr()

rootDir  = joinpath(dirname(pathof(DirectConvolution)), "..")
dataDir = joinpath(rootDir,"data")

```

# Use cases

These demos use data stored in the `data/` folder.
```@repl session_1
dataDir
```

There are one 1D signal and one 2D signal:
```@example session_1
data_1D = readdlm(joinpath(dataDir,"signal_1.csv"),','); 
data_1D_x = @view data_1D[:,1]
data_1D_y = @view data_1D[:,2]
plot(data_1D_x,data_1D_y) 
```
```@example session_1
data_2D=readdlm(joinpath(dataDir,"surface.data"));
surface(data_2D,label="2D signal")
```

## Savitzky-Golay filters

### Filter creation

Creates a set of Savitzky-Golay filters using polynomial of degree $3$
with a window width of $11=2\times 5+1$.


```@example session_1
sg = SG_Filter(Float64,halfWidth=5,degree=3);
```

This can be checked with 

```@repl session_1
length(sg)
polynomialOrder(sg)
```

### 1D signal smoothing

To apply one filter on a 1D signal:
```@example session_1
data_1D_y_smoothed = apply_SG_filter(data_1D_y,sg,derivativeOrder=0)

plot(data_1D_x,data_1D_y)
plot!(data_1D_x,data_1D_y_smoothed)
```

### 2D signal smoothing

To apply one filter on a 2D signal
```@example session_1
sg_I = SG_Filter(Float64,halfWidth=5,degree=3);
sg_J = SG_Filter(Float64,halfWidth=3,degree=3);

data_2D_smoothed = apply_SG_filter2D(data_2D,
                               sg_I,
                               sg_J,
                               derivativeOrder_I=0,
                               derivativeOrder_J=0)

surface(data_2D_smoothed,label="Smoothed 2D signal");
```

## Wavelet transform

Use some wavelet filter

```@example session_1
filter = UDWT_Filter_Starck2{Float64}()
```

Perform a UDWT transform
```@example session_1
data_1D_udwt = udwt(data_1D_y,filter,scale=8)
```

Plot Results:


```@example session_1
label=["W$i" for i in 1:scale(data_1D_udwt)];
plot(data_1D_udwt.W,label=reshape(label,1,scale(data_1D_udwt)))
plot!(data_1D_udwt.V,label="V$(scale(data_1D_udwt))");
plot!(data_1D_y,label="signal")
```


# API


```@index
```

```@autodocs
Modules = [DirectConvolution]
```
