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

Base.broadcast(::typeof(==),f::LinearFilter{T},v::AbstractArray{T,1}) where {T<:Number} = (fcoef(f)==v)
