export UDWT_Filter_Haar

abstract type UDWT_Filter_Biorthogonal end
abstract type UDWT_Filter <: UDWT_Filter_Biorthogonal end

function ϕ end
function ψ end
function tildeϕ end
function tildeψ end
function ϕ_offset end
function ψ_offset end
function tildeϕ_offset end
function tildeψ_offset end


tildeϕ(c::UDWT_Filter)=ϕ(c)
tildeψ(c::UDWT_Filter)=ψ(c)
tildeϕ_offset(c::UDWT_Filter)=ϕ_offset(c)
tildeψ_offset(c::UDWT_Filter)=ψ_offset(c)

# struct UDWT_Filter_Default{T<:Real,ϕN,ψN}
#     _ϕ::SVector{ϕN,T}
#     _ψ::SVector{ψN,T}
#     _ϕ_offset::Int
#     _ψ_offset::Int
# end

struct UDWT_Filter_Haar{T<:Real} <: UDWT_Filter
    _ϕ::SVector{2,T}
    _ψ::SVector{2,T}
    _ϕ_offset::Int
    _ψ_offset::Int

    UDWT_Filter_Haar{T}() where {T<:Real} = new(SVector{2,T}([sqrt(2.)*1/2 sqrt(2.)*1/2]),
                                                SVector{2,T}([sqrt(2.)*1/2 -sqrt(2.)*1/2]),
                                                0,
                                                0)
end

                              
