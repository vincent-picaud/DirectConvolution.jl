export UDWT_Filter_Haar
export ϕ_filter,ψ_filter,tildeϕ_filter,tildeψ_filter,ϕ_offset,ψ_offset,tildeϕ_offset,tildeψ_offset



abstract type UDWT_Filter_Biorthogonal end
abstract type UDWT_Filter <: UDWT_Filter_Biorthogonal end

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

ϕ_filter(udwt_filter::UDWT_Filter_Haar{T}) where {T} = udwt_filter._ϕ
ψ_filter(udwt_filter::UDWT_Filter_Haar{T}) where {T} = udwt_filter._ψ
ϕ_offset(udwt_filter::UDWT_Filter_Haar{T}) where {T} = udwt_filter._ϕ_offset
ψ_offset(udwt_filter::UDWT_Filter_Haar{T}) where {T} = udwt_filter._ψ_offset
