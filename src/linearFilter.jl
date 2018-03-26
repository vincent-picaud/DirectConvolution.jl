export fcoef, length, offset, range


# [BEGIN_AbstractLinearFilter]

abstract type LinearFilter{T<:Number} end

# [END_AbstractLinearFilter]

# [BEGIN_AbstractLinearFilterMethods]
fcoef(c::LinearFilter) = c._fcoef
Base.length(c::LinearFilter) = length(fcoef(c))
offset(c::LinearFilter) = c._offset
Base.range(c::LinearFilter) = UnitRange(-offset(c),length(c)-offset(c)-1)
# [END_AbstractLinearFilterMethods]

# for convenience only, used in utests
function Base.isapprox(f::LinearFilter{T},v::AbstractArray{T,1}) where {T<:Number}
    return isapprox(fcoef(f),v)
end



#
# Provide a default implementation
#

#+LinearFilter
# Default linear filter
struct LinearFilter_Default{T<:AbstractFloat,N} <: LinearFilter{T}
    _fcoef::SVector{N,T}
    _offset::Int
end



#
# Provide a default implementation of size 2n+1, with offset = n
#

#+LinearFilter
# Default centered linear filter, size = 2n+1
# 
struct LinearFilter_DefaultCentered{T<:AbstractFloat,N} <: LinearFilter{T}
    _fcoef::SVector{N,T}
end

#+LinearFilter
# Creates a centered linear filter from an array of size = 2n+1
# 
function LinearFilter_DefaultCentered(c::Array{T}) where {T<:AbstractFloat}  # [END_LinearFilter_DefaultCentered]
    const N = length(c)
    @assert isodd(length(c))
    return LinearFilter_DefaultCentered{T,N}(SVector{N,T}(c))
end

#+LinearFilter
# Returns offset, if size = 2n+1 then offset = n
# 
offset(f::LinearFilter_DefaultCentered{T,N}) where {T<:AbstractFloat,N} = (N-1)>>1

