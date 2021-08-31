export LinearFilter
export fcoef, length, offset, range

import Base: length,range,isapprox



"""
    abstract type LinearFilter{T<:Number} end

Abstract type defining a linear filter. 
"""
abstract type LinearFilter{T<:Number} end

"""
    fcoef(c::LinearFilter) 

Returns filter coefficients
"""
fcoef(c::LinearFilter) = c._fcoef

"""
    length(c::LinearFilter)::Int

Returns filter length
"""
length(c::LinearFilter)::Int = length(fcoef(c))

"""
    offset(c::LinearFilter)::Int

Returns filter offset

**Caveat:** the first position is **0** (and not **1**)
"""
offset(c::LinearFilter)::Int = c._offset

# Internal
#
# Computes [[range_filter][]] using primitive types.
# This allows reuse by =directConv!= for instance.
#
# *Caveat:* do not overload Base.range !!! 
filter_range(size::Int,offset::Int)::UnitRange = UnitRange(-offset,size-offset-1)

"""
    range(c::LinearFilter)::UnitRange

Returns filter range Ω

Filter support of a filter α is defined by Ω = [ - offset(α), length(α) -  offset(α) - 1 ]
"""
range(c::LinearFilter)::UnitRange = filter_range(length(c),offset(c))


# For convenience only, used in utests
#
function isapprox(f::LinearFilter{T},v::AbstractArray{T,1}) where {T<:Number}
    return isapprox(fcoef(f),v)
end

"""
    struct LinearFilter_Default{T<:Number,N}

Default linear filter.

You can create a filter as follows

```jldoctest
julia> linear_filter=LinearFilter([1,-2,1],1)
DirectConvolution.LinearFilter_Default{Int64, 3}([1, -2, 1], 1)


julia> offset(linear_filter)
1


julia> range(linear_filter)
-1:1
```
"""
struct LinearFilter_Default{T<:Number,N} <: LinearFilter{T}
    _fcoef::SVector{N,T}
    _offset::Int
end

#+LinearFilter,Internal 
# Creates a linear filter from a coefficient vector and its associated offset
#
# *Example:*
#!linear_filter=LinearFilter(rand(3),5)
#!offset(linear_filter)
#!range(linear_filter)
#
function LinearFilter_Default(c::AbstractArray{T,1},offset::Int)  where {T<:Number}
    v=SVector{length(c),T}(c)
    return LinearFilter_Default{T,length(c)}(v,offset)
end



#+LinearFilter,Internal
#
# Default *centered* linear filter
#
# Array length has to be odd, 2n+1. Filter offset is n by construction.
#
struct LinearFilter_DefaultCentered{T<:Number,N} <: LinearFilter{T}
    _fcoef::SVector{N,T}
end

#+LinearFilter,Internal
function LinearFilter_DefaultCentered(c::AbstractArray{T,1}) where {T<:Number} 
    N = length(c)
    @assert isodd(length(c)) "Centered filters must have an odd number of coefficients, $N is even"
    return LinearFilter_DefaultCentered{T,N}(SVector{N,T}(c))
end

#+LinearFilter,Internal 
offset(f::LinearFilter_DefaultCentered{T,N}) where {T<:Number,N} = (N-1)>>1



# Once that we have defined LinearFilter_Default and
# LinearFilter_DefaultCentered we can unify construction. Switch to
# the right type is decided according to arguments


#+LinearFilter
#
# Creates a linear filter from its coefficients and an offset
#
# The *offset* is the position of the filter coefficient to be aligned with zero, see [[range_filter][]].
#
# *Example:*
#!f=LinearFilter([0:5;],4);
#!hcat([range(f);],fcoef(f))
#
function LinearFilter(c::AbstractArray{T,1},offset::Int)::LinearFilter  where {T}
    return LinearFilter_Default(c,offset)
end

#+LinearFilter
#
# Creates a centered linear filter, it must have an odd number of
# coefficients, $2n+1$ and is centered by construction (offset=n)
#
# *Example:*
#!f=LinearFilter([0:4;]);
#!hcat([range(f);],fcoef(f))
#
function LinearFilter(c::AbstractArray{T,1})::LinearFilter  where {T}
    return LinearFilter_DefaultCentered(c)
end
