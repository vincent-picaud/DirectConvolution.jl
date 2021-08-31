# DirectConvolution

[![Build Status](https://travis-ci.org/vincent-picaud/DirectConvolution.jl.svg?branch=master)](https://travis-ci.org/vincent-picaud/DirectConvolution.jl) 
[![codecov.io](http://codecov.io/github/vincent-picaud/DirectConvolution.jl/coverage.svg?branch=master)](http://codecov.io/github/vincent-picaud/DirectConvolution.jl?branch=master)

This package provides functions related to convolution products using
direct (no FFT) methods. For short filters this approach is faster and
more versatile than the Julia native conv(...) function.

Currently supported features:
- 1D convolution, cross-correlation, boundary extensions...
- Savitzky-Golay filters
- Undecimated Wavelet Transform

![udwt](https://github.com/vincent-picaud/DirectConvolution.jl/blob/master/docs/use_cases/UDW/figures/W.png)

You can read documentation directly
[here](https://vincent-picaud.github.io/DirectConvolution.jl/index.html),
however if you want to use the css theme you must clone this repo and browse it locally:

```
firefox docs/index.html
```



