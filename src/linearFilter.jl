export LinearFilter,LinearFilter_Default, LinearFilter_CenteredDefault,
    fcoef, length, offset, range

import Base: length,range,isapprox


#+LinearFilter L:LinearFilter
#
# Abstract type defining a linear filter
#
abstract type LinearFilter{T<:Number} end
 
#+LinearFilter
# Returns filter coefficients as a Vector type 
#!linear_filter=LinearFilter_Default(rand(3),0);
#!fcoef(linear_filter)
fcoef(c::LinearFilter) = c._fcoef

#+LinearFilter 
# Returns filter length
length(c::LinearFilter) = length(fcoef(c))
#+LinearFilter 
# Returns filter offset
offset(c::LinearFilter)::Int = c._offset
#+LinearFilter 
# Returns filter range
#!linear_filter=LinearFilter_Default(rand(3),5);
#!range(linear_filter)
range(c::LinearFilter)::UnitRange = UnitRange(-offset(c),length(c)-offset(c)-1)


#+Internal 
# For convenience only, used in utests
function isapprox(f::LinearFilter{T},v::AbstractArray{T,1}) where {T<:Number}
    return isapprox(fcoef(f),v)
end


#

#+LinearFilter
# Default linear filter
#
struct LinearFilter_Default{T<:AbstractFloat,N} <: LinearFilter{T}
    _fcoef::SVector{N,T}
    _offset::Int
end

#+LinearFilter
# Creates a linear filter from a coefficient vector and its associated offset
#
# *Example:*
#!linear_filter=LinearFilter_Default(rand(3),5)
#!offset(linear_filter)
#!range(linear_filter)
#
function LinearFilter_Default(c::AbstractArray{T,1},offset::Int)  where {T<:AbstractFloat}
    v=SVector{length(c),T}(c)
    return LinearFilter_Default{T,length(c)}(v,offset)
end



#+LinearFilter L:LinearFilter_DefaultCentered
# Default *centered* linear filter
struct LinearFilter_DefaultCentered{T<:AbstractFloat,N} <: LinearFilter{T}
    _fcoef::SVector{N,T}
end

#+LinearFilter 
# Creates a centered linear filter
#
# Array length has to be odd, 2n+1. Filter offset is n by construction.
#
#!linear_filter=LinearFilter_DefaultCentered(rand(3));
#!fcoef(linear_filter)
#!range(linear_filter)
#
function LinearFilter_DefaultCentered(c::AbstractArray{T,1}) where {T<:AbstractFloat} 
    const N = length(c)
    @assert isodd(length(c))
    return LinearFilter_DefaultCentered{T,N}(SVector{N,T}(c))
end

#+LinearFilter 
# Returns offset, [LinearFilter_DefaultCentered][]] specialization
# 
offset(f::LinearFilter_DefaultCentered{T,N}) where {T<:AbstractFloat,N} = (N-1)>>1

