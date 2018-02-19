export SG_Filter


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

    for i in 1:size(SG,1)
        SG[i,:]*=factorial(i-1)
    end
    
# CAVEAT: returns the transposed matrix
    
    return SG'
end
