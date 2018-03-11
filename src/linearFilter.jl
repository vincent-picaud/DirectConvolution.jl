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

