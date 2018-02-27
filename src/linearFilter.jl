export filter, length, offset, range

abstract type LinearFilter{T<:Number} end

Base.filter(c::LinearFilter) = c._filter
Base.length(c::LinearFilter) = length(filter(c))
offset(c::LinearFilter) = c._offset
Base.range(c::LinearFilter) = UnitRange(-offset(c),length(c)-offset(c)-1)
