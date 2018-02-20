export UDWT_Filter_Haar
export ϕ_filter,ψ_filter,tildeϕ_filter,tildeψ_filter,ϕ_offset,ψ_offset,tildeϕ_offset,tildeψ_offset
export udwt



abstract type UDWT_Filter_Biorthogonal{T<:Number} end
abstract type UDWT_Filter{T<:Number} <: UDWT_Filter_Biorthogonal{T} end

function ϕ_filter end
function ψ_filter end
function tildeϕ_filter end
function tildeψ_filter end
function ϕ_offset end
function ψ_offset end
function tildeϕ_offset end
function tildeψ_offset end



tildeϕ_filter(c::UDWT_Filter)=ϕ_filter(c)
tildeψ_filter(c::UDWT_Filter)=ψ_filter(c)
tildeϕ_offset(c::UDWT_Filter)=ϕ_offset(c)
tildeψ_offset(c::UDWT_Filter)=ψ_offset(c)



struct UDWT_Filter_Haar{T<:AbstractFloat} <: UDWT_Filter{T}
    _ϕ::SVector{2,T}
    _ψ::SVector{2,T}
    _ϕ_offset::Int
    _ψ_offset::Int

    UDWT_Filter_Haar{T}() where {T<:Real} = new(SVector{2,T}([sqrt(2.)*1/2 sqrt(2.)*1/2]),
                                                SVector{2,T}([sqrt(2.)*1/2 -sqrt(2.)*1/2]),
                                                0,
                                                0)
end

ϕ_filter(udwt_filter::UDWT_Filter_Haar{T}) where {T} = udwt_filter._ϕ
ψ_filter(udwt_filter::UDWT_Filter_Haar{T}) where {T} = udwt_filter._ψ
ϕ_offset(udwt_filter::UDWT_Filter_Haar{T}) where {T} = udwt_filter._ϕ_offset
ψ_offset(udwt_filter::UDWT_Filter_Haar{T}) where {T} = udwt_filter._ψ_offset



struct UDWT{T<:Number} 
    W::Array{T,2}
    V::Array{T,1}

    UDWT{T}(;n::Int=0,scale::Int=0) where {T<:Number} = new(Array{T,2}(scale,n),
                                                       Array{T,1}(n))
end

doc"""

Performs a 1D undecimated wavelet transform

$$\mathcal{W}_{j+1}f)[u]=(\bar{g}_j*(\mathcal{V}_{j}f)[u]$$
$$\mathcal{V}_{j+1}f)[u]=(\bar{h}_j*(\mathcal{V}_{j}f)[u]$$
"""
function udwt(signal::AbstractArray{T,1},filter::UDWT_Filter_Biorthogonal{T};scale::Int=3) where {T<:Number}

    @assert scale>=0

    const boundary = :ZeroPadding
    const n_signal = length(signal)
    const udwt_domain = UDWT{T}(n=n_signal,scale=scale)
    const Ωγ = 1:n_signal

    Vs = Array{T,1}(n_signal)
    Vsp1 = Array{T,1}(n_signal)
    Vs .= signal
    
    for s in 1:scale
        const twoPowScale = 2^(s-1)
        const Wsp1 = @view udwt_domain.W[s,:]
        
        # Compute Vs+1 from Vs
        #
        directConv!(ϕ_filter(filter),
                    ϕ_offset(filter),
                    twoPowScale,

                    Vs,
                    
                    Vsp1,
                    Ωγ,
                      
                    boundary,
                    boundary)

        # Compute Ws+1 from Ws
        #
        
        directConv!(ψ_filter(filter),
                    ψ_offset(filter),
                    twoPowScale,

                    Vs,
                    
                    Wsp1,
                    Ωγ,
                      
                    boundary,
                    boundary)

        Vs=Vsp1 # shallow copy
    end

    udwt_domain.V .= Vs

    return udwt_domain
end
