export SG_Filter
export SavitzkyGolay_Filter, SG_Filter
export maxDerivativeOrder, polynomialOrder

import Base: filter, length

function _Vandermonde(T::DataType=Float64;halfWidth::Int=5,degree::Int=2)::Array{T,2}
    
    @assert halfWidth>=0
    @assert degree>=0
    
    x=T[i for i in -halfWidth:halfWidth]

    n = degree+1
    m = length(x)
    
    V = Array{T}(m, n)
    
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


#+SG_Filters
#
# A structure to store Savitzky-Golay filters.
#
struct SG_Filter{T<:AbstractFloat,N}
    _filter_set::Array{LinearFilter_DefaultCentered{T,N},1}
end
#+SG_Filters
#
# Returns the filter to be used to compute the  smoothed derivatives of order *derivativeOrder*.
#
filter(sg::SG_Filter{T,N};derivativeOrder::Int=0) where {T<:AbstractFloat,N} = sg._filter_set[derivativeOrder+1]
#+SG_Filters
#
# Returns filter length, this is an odd number, see [[SG_Filters_Constructor][]]
length(sg::SG_Filter{T,N}) where {T<:AbstractFloat,N} = length(filter(sg))
#+SG_Filters
#
# Maximum order of the smoothed derivatives we can compute with *sg*
#
maxDerivativeOrder(sg::SG_Filter{T,N}) where {T<:AbstractFloat,N} = size(sg._filter_set,1)-1
#+SG_Filters
# Returns the degree of the polynomial used to construct the Savitzky-Golay filters, see [[SG_Filters_Constructor][]].
polynomialOrder(sg::SG_Filter{T,N}) where {T<:AbstractFloat,N} = maxDerivativeOrder(sg)
    
#+SG_Filters L:SG_Filters_Constructor
#
# Creates a set of Savitzky-Golay filters
#
# - filter length is 2*halfWidth+1
# - polynomial degree is degree
#
function SG_Filter(T::DataType=Float64;halfWidth::Int=5,degree::Int=2)
    @assert degree>=0
    @assert halfWidth>=1
    @assert 2*halfWidth>degree
    
    V=_Vandermonde(T,halfWidth=halfWidth,degree=degree)
    Q,R=qr(V)
    SG=R\Q'

    const n_filter,n_coef = size(SG)
    const sg_type = LinearFilter_DefaultCentered{T,n_coef}

    buffer=Array{sg_type,1}()
    
    for i in 1:n_filter
        SG[i,:]*=factorial(i-1)
        push!(buffer,sg_type(SVector{n_coef,T}(SG[i,:])))
    end
    
# Returns filters set
    return SG_Filter{T,n_coef}(buffer)
end
