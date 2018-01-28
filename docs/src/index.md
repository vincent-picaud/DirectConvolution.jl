# Direct Convolution

For small kernels this approach is more efficient than FFT


```math
\gamma[k]=\sum\limits_{i\in\Omega^\alpha}\alpha[i]\beta[k+\lambda i],\text{ with }\lambda\in\mathbb{Z}^*
``` 


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