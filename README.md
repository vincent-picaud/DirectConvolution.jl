# DirectConvolution

[![Build Status](https://travis-ci.org/vincent-picaud/DirectConvolution.jl.svg?branch=master)](https://travis-ci.org/vincent-picaud/DirectConvolution.jl) 
[![codecov.io](http://codecov.io/github/vincent-picaud/DirectConvolution.jl/coverage.svg?branch=master)](http://codecov.io/github/vincent-picaud/DirectConvolution.jl?branch=master)

This package goal is to compute convolution products using direct (no
FFT) methods. This can be useful for short filters, like those used in
wavelet transform:

![udwt](https://github.com/vincent-picaud/DirectConvolution.jl/blob/master/docs/use_cases/udwt_figures/W.png)

You can read documentation directly
[here](https://vincent-picaud.github.io/DirectConvolution.jl/index.html),
however it is much better to clone this repo and to browse it locally:

```
firefox docs/index.html
```



