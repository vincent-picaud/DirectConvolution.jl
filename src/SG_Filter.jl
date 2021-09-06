export SG_Filter, maxDerivativeOrder, polynomialOrder, apply_SG_filter, apply_SG_filter2D

import Base: filter, length

function _Vandermonde(T::DataType=Float64;halfWidth::Int=5,degree::Int=2)::Array{T,2}
    
    @assert halfWidth>=0
    @assert degree>=0
    
    x=T[i for i in -halfWidth:halfWidth]

    n = degree+1
    m = length(x)
    
    V = Array{T}(undef,m, n)
    
    for i = 1:m
        V[i,1] = T(1)
    end
    for j = 2:n
        for i = 1:m
            V[i,j] = x[i] * V[i,j-1]
        end
    end

    return V
end

# ================================================================

struct SG_Filter{T<:AbstractFloat,N}
    _filter_set::Array{LinearFilter_DefaultCentered{T,N},1}
end

"""
    function SG_Filter(T::DataType=Float64;halfWidth::Int=5,degree::Int=2)

Creates a `SG_Filter` structure used to store Savitzky-Golay filters.

* filter length is 2*`halfWidth`+1 
* polynomial degree is `degree`, which defines `maxDerivativeOrder`

You can apply these filters using the 
* `apply_SG_filter`
* `apply_SG_filter2D`
functions.

Example:

```jldoctest
julia> sg = SG_Filter(halfWidth=5,degree=3);


julia> maxDerivativeOrder(sg)
3

julia> length(sg)
11

julia> filter(sg,derivativeOrder=2)
Filter(r=-5:5,c=[0.03497, 0.01399, -0.002331, -0.01399, -0.02098, -0.02331, -0.02098, -0.01399, -0.002331, 0.01399, 0.03497])

```
"""
function SG_Filter(T::DataType=Float64;halfWidth::Int=5,degree::Int=2)::SG_Filter
    @assert degree>=0
    @assert halfWidth>=1
    @assert 2*halfWidth>degree
    
    V=_Vandermonde(T,halfWidth=halfWidth,degree=degree)
    Q,R=qr(V)
    # breaking change in Julia V1.0,
    # see https://github.com/JuliaLang/julia/issues/27397
    #
    # before Q was a "plain" matrix, now stored in compact form
    #
    # SG=R\Q'
    #
    # must be replaced by
    #
    # Q=Q*Matrix(I, size(V))
    # SG=R\Q'
    #
    Q=Q*Matrix(I, size(V))
    SG=R\Q'

    n_filter,n_coef = size(SG)

    buffer=Array{LinearFilter_DefaultCentered{T,n_coef},1}()
    
    for i in 1:n_filter
        SG[i,:]*=factorial(i-1)
        push!(buffer,LinearFilter(SG[i,:]))
    end
    
# Returns filters set
    return SG_Filter{T,n_coef}(buffer)
end

# ================================================================

"""
    function filter(sg::SG_Filter{T,N};derivativeOrder::Int=0)

Returns the filter to be used to compute the smoothed derivatives of order `derivativeOrder`.

See: `SG_Filter`
"""
function filter(sg::SG_Filter{T,N};derivativeOrder::Int=0) where {T<:AbstractFloat,N}
    @assert 0<= derivativeOrder <= maxDerivativeOrder(sg)
    return sg._filter_set[derivativeOrder+1]
end 

"""
    function length(sg::SG_Filter{T,N})

Returns filter length, this is an odd number.

See: `SG_Filter`
"""
Base.length(sg::SG_Filter{T,N}) where {T<:AbstractFloat,N} = length(filter(sg))

"""
    function maxDerivativeOrder(sg::SG_Filter{T,N})

Maximum order of the smoothed derivatives we can compute using `sg` filters.

See: `SG_Filter`
"""
maxDerivativeOrder(sg::SG_Filter{T,N}) where {T<:AbstractFloat,N} = size(sg._filter_set,1)-1

"""
    function polynomialOrder(sg::SG_Filter{T,N})

Returns the degree of the polynomial used to construct the
Savitzky-Golay filters. This is mainly a 'convenience' function, as it
is equivalent to `maxDerivativeOrder`

See: `SG_Filter`
"""
polynomialOrder(sg::SG_Filter{T,N}) where {T<:AbstractFloat,N} = maxDerivativeOrder(sg)

"""
    function apply_SG_filter(signal::Array{T,1},
                             sg::SG_Filter{T};
                             derivativeOrder::Int=0,
                             left_BE::Type{<:BoundaryExtension}=ConstantBE,
                             right_BE::Type{<:BoundaryExtension}=ConstantBE)



Applies an 1D Savitzky-Golay and returns the smoothed signal.
"""
function apply_SG_filter(signal::AbstractArray{T,1},
                         sg::SG_Filter{T};
                         derivativeOrder::Int=0,
                         left_BE::Type{<:BoundaryExtension}=ConstantBE,
                         right_BE::Type{<:BoundaryExtension}=ConstantBE) where {T<:AbstractFloat}
    
    return directCrossCorrelation(filter(sg,derivativeOrder=derivativeOrder),
                                  signal,
                                  left_BE,
                                  right_BE)
end

"""
    function apply_SG_filter2D(signal::Array{T,2},
                               sg_I::SG_Filter{T},
                               sg_J::SG_Filter{T};
                               derivativeOrder_I::Int=0,
                               derivativeOrder_J::Int=0,
                               min_I_BE::Type{<:BoundaryExtension}=ConstantBE,
                               max_I_BE::Type{<:BoundaryExtension}=ConstantBE,
                               min_J_BE::Type{<:BoundaryExtension}=ConstantBE,
                               max_J_BE::Type{<:BoundaryExtension}=ConstantBE)

Applies an 2D Savitzky-Golay and returns the smoothed signal.
"""
function apply_SG_filter2D(signal::AbstractArray{T,2},
                           sg_I::SG_Filter{T},
                           sg_J::SG_Filter{T};
                           derivativeOrder_I::Int=0,
                           derivativeOrder_J::Int=0,
                           min_I_BE::Type{<:BoundaryExtension}=ConstantBE,
                           max_I_BE::Type{<:BoundaryExtension}=ConstantBE,
                           min_J_BE::Type{<:BoundaryExtension}=ConstantBE,
                           max_J_BE::Type{<:BoundaryExtension}=ConstantBE) where {T<:AbstractFloat}
    
    return directCrossCorrelation2D(filter(sg_I,derivativeOrder=derivativeOrder_I),
                                    filter(sg_J,derivativeOrder=derivativeOrder_J),
                                    signal,
                                    min_I_BE,
                                    max_I_BE,
                                    min_J_BE,
                                    max_J_BE)
end 
