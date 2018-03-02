export SG_Filter
export SavitzkyGolay_Filter, SavitzkyGolay_Filter_Set
export maxDerivativeOrder, polynomialOrder

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

struct SavitzkyGolay_Filter{T<:AbstractFloat,N} <: LinearFilter{T}
    _filter::SVector{N,T}
end

function SavitzkyGolay_Filter(c::Array{T}) where {T<:AbstractFloat}
    const N = length(c)
    @assert isodd(length(c))
    return SavitzkyGolay_Filter{T,N}(SVector{N,T}(c))
end


offset(f::SavitzkyGolay_Filter{T,N}) where {T<:AbstractFloat,N} = (N-1)>>1

# todo
struct SavitzkyGolay_Filter_Set{T<:AbstractFloat,N}
    _filter_set::Array{SavitzkyGolay_Filter{T,N},1}
end

Base.filter(sg::SavitzkyGolay_Filter_Set{T,N};derivativeOrder::Int=0) where {T<:AbstractFloat,N} = sg._filter_set[derivativeOrder+1]
Base.length(sg::SavitzkyGolay_Filter_Set{T,N}) where {T<:AbstractFloat,N} = length(filter(sg))
maxDerivativeOrder(sg::SavitzkyGolay_Filter_Set{T,N}) where {T<:AbstractFloat,N} = size(sg._filter_set,1)-1
polynomialOrder(sg::SavitzkyGolay_Filter_Set{T,N}) where {T<:AbstractFloat,N} = maxDerivativeOrder(sg)
    
doc"""
    SG_Filter(;halfWidth::Int=5,degree=2,T::Type=Float64)::Array{T,2}

Returns Savitzky-Golay filter matrix.

- filter length is 2*halfWidth+1
- polynomial degree is degree
"""                        
function SG_Filter(T::DataType=Float64;halfWidth::Int=5,degree::Int=2)
    @assert degree>=0
    @assert halfWidth>=1
    @assert 2*halfWidth>degree
    
    V=_Vandermonde(T,halfWidth=halfWidth,degree=degree)
    Q,R=qr(V)
    SG=R\Q'

    const n_filter,n_coef = size(SG)
    const sg_type = SavitzkyGolay_Filter{T,n_coef}

    buffer=Array{sg_type,1}()
    
    for i in 1:n_filter
        SG[i,:]*=factorial(i-1)
        push!(buffer,sg_type(SVector{n_coef,T}(SG[i,:])))
    end
    
# Returns filters set
    return SavitzkyGolay_Filter_Set{T,n_coef}(buffer)
end
