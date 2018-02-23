export UDWT_Filter_Haar
export ϕ_filter,ψ_filter,tildeϕ_filter,tildeψ_filter,ϕ_offset,ψ_offset,tildeϕ_offset,tildeψ_offset
export udwt, scale, inverse_udwt!



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
                                                SVector{2,T}([-sqrt(2.)*1/2 sqrt(2.)*1/2]),
                                                1,
                                                1)
end

ϕ_filter(udwt_filter::UDWT_Filter_Haar{T}) where {T} = udwt_filter._ϕ
ψ_filter(udwt_filter::UDWT_Filter_Haar{T}) where {T} = udwt_filter._ψ
ϕ_offset(udwt_filter::UDWT_Filter_Haar{T}) where {T} = udwt_filter._ϕ_offset
ψ_offset(udwt_filter::UDWT_Filter_Haar{T}) where {T} = udwt_filter._ψ_offset



struct UDWT{T<:Number}

    filter::UDWT_Filter_Biorthogonal{T}
    # TODO also store boundary condition

    W::Array{T,2}
    V::Array{T,1}

    UDWT{T}(filter::UDWT_Filter_Biorthogonal{T};
            n::Int=0,
            scale::Int=0) where {T<:Number} =
                new(filter,
                    Array{T,2}(scale,n),
                    Array{T,1}(n))
end

scale(udwt::UDWT)::Int = size(udwt.W,1)
Base.length(udwt::UDWT)::Int = size(udwt.W,2)

doc"""

Performs a 1D undecimated wavelet transform

$$\mathcal{W}_{j+1}f)[u]=(\bar{g}_j*(\mathcal{V}_{j}f)[u]$$
$$\mathcal{V}_{j+1}f)[u]=(\bar{h}_j*(\mathcal{V}_{j}f)[u]$$
"""
function udwt(signal::AbstractArray{T,1},filter::UDWT_Filter_Biorthogonal{T};scale::Int=3) where {T<:Number}

    @assert scale>=0

    const boundary = PeriodicBE
    const n = length(signal)
    const udwt_domain = UDWT{T}(filter,n=n,scale=scale)
    const Ωγ = 1:n

    Vs = Array{T,1}(n)
    Vsp1 = Array{T,1}(n)
    Vs .= signal

    for s in 1:scale
        const twoPowScale = 2^(s-1)
        const Wsp1 = @view udwt_domain.W[s,:]
        
        # Computes Vs+1 from Vs
        #
        directConv!(ϕ_filter(filter),
                    ϕ_offset(filter),
                    twoPowScale,

                    Vs,
                    
                    Vsp1,
                    Ωγ,
                      
                    boundary,
                    boundary)

       
        # Computes Ws+1 from Ws
        #
        directConv!(ψ_filter(filter),
                    ψ_offset(filter),
                    twoPowScale,

                    Vs,
                    
                    Wsp1,
                    Ωγ,
                      
                    boundary,
                    boundary)

        @swap(Vs,Vsp1)
        
    end

    udwt_domain.V .= Vs

    return udwt_domain
end

doc"""

Performs an inverse 1D undecimated wavelet transform
"""
function inverse_udwt!(udwt_domain::UDWT{T},signal::AbstractArray{T,1}) where {T<:Number}

    @assert length(udwt_domain) == length(signal)

    const boundary = PeriodicBE
    const maxScale = scale(udwt_domain)
    const n = length(signal)
    const Ωγ = 1:n
    const buffer = Array{T,1}(n)
    
    signal .= udwt_domain.V

    
    for s in maxScale:-1:1
        const twoPowScale = 2^(s-1)
        
        # Computes Vs from Vs+1
        #
        directConv!(tildeϕ_filter(udwt_domain.filter),
                    tildeϕ_offset(udwt_domain.filter),
                    -twoPowScale,
                    
                    signal,
                    
                    buffer,
                    Ωγ,
                      
                    boundary,
                    boundary)

        # Computes Ws from Ws+1
        #
        const Ws = @view udwt_domain.W[s,:]

        directConv!(tildeψ_filter(udwt_domain.filter),
                    tildeψ_offset(udwt_domain.filter),
                    -twoPowScale,
                    
                    Ws,
                    
                    buffer,
                    Ωγ,
                      
                    boundary,
                    boundary,
                    accumulate=true)

        for i in Ωγ
            signal[i]=0.5*buffer[i]
        end
    end
end
