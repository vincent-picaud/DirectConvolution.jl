#+LinearFilter
export LinearFilter,LinearFilter_Default, LinearFilter_CenteredDefault,
    fcoef, length, offset, range

import Base: length,range,isapprox


#+LinearFilter
# Abstract type defining a linear filter
#
abstract type LinearFilter{T<:Number} end
 
#+LinearFilter
# Returns filter coefficients as a Vector type 
fcoef(c::LinearFilter) = c._fcoef
#+LinearFilter
# Returns filter length
length(c::LinearFilter) = length(fcoef(c))
#+LinearFilter
# Returns filter offset
offset(c::LinearFilter) = c._offset
#+LinearFilter
# Returns filter range
range(c::LinearFilter) = UnitRange(-offset(c),length(c)-offset(c)-1)


#+Internal 
# For convenience only, used in utests
function isapprox(f::LinearFilter{T},v::AbstractArray{T,1}) where {T<:Number}
    return isapprox(fcoef(f),v)
end


#

#+LinearFilter
# Default linear filter
struct LinearFilter_Default{T<:AbstractFloat,N} <: LinearFilter{T}
    _fcoef::SVector{N,T}
    _offset::Int
end

#+LinearFilter
# Creates a linear filter from a coefficient vector and its associated offset
function LinearFilter_Default(c::AbstractArray{T,1},offset::Int)  where {T<:AbstractFloat}
    v=SVector{length(c),T}(c)
    return LinearFilter_Default{T,length(c)}(v,offset)
end



#+LinearFilter
# Provides a default implementation of size 2n+1, with offset = n
# 
struct LinearFilter_DefaultCentered{T<:AbstractFloat,N} <: LinearFilter{T}
    _fcoef::SVector{N,T}
end

#+LinearFilter
# Creates a centered linear filter from an array of size = 2n+1
# 
function LinearFilter_DefaultCentered(c::Array{T}) where {T<:AbstractFloat} 
    const N = length(c)
    @assert isodd(length(c))
    return LinearFilter_DefaultCentered{T,N}(SVector{N,T}(c))
end

#+LinearFilter
# Returns offset, if size = 2n+1 then offset = n
# 
offset(f::LinearFilter_DefaultCentered{T,N}) where {T<:AbstractFloat,N} = (N-1)>>1

