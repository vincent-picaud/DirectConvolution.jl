```@meta
CurrentModule = DirectConvolution
```

# DirectConvolution

Documentation for [DirectConvolution](https://github.com/vincent-picaud/DirectConvolution.jl).
```@setup session_1
using DirectConvolution
using DelimitedFiles
using Plots

rootDir  = joinpath(dirname(pathof(DirectConvolution)), "..")
dataDir = joinpath(rootDir,"data")

```

# Use cases

These demos use data stored in the `data/` folder.


```julia
data_1D = readdlm("data/signal_1.csv",',')
Plots.plot(data_1D[:,1],data_1D[:,2])
```

```@setup session_1
data_1D=readdlm(joinpath(dataDir,"signal_1.csv"),',')
p=Plots.plot(data_1D[:,1],data_1D[:,2]);
Plots.savefig(p,"plot_signal_1.png")
```

![](plot_signal_1.png)

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

```@autodocs
Modules = [DirectConvolution]
```
