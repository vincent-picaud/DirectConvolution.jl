module DirectConvolution

function scale(λ::Int64,Ω::UnitRange)
    ifelse(λ>0,
           UnitRange(λ*start(Ω),λ*last(Ω)),
           UnitRange(λ*last(Ω),λ*start(Ω)))
end

function compute_Ωγ1(Ωα::UnitRange,
                     λ::Int64,
                     Ωβ::UnitRange)
    
    λΩα = scale(λ,Ωα)

    UnitRange(start(Ωβ)-start(λΩα),
              last(Ωβ)-last(λΩα))
end

# Left & Right relative complements A\B
#
function relelativeComplement_left(A::UnitRange,
                                   B::UnitRange)
    UnitRange(start(A),
              min(last(A),start(B)-1))
end

function relelativeComplement_right(A::UnitRange,
                                    B::UnitRange)
    UnitRange(max(start(A),last(B)+1),
              last(A))
end

const tilde_i0 = Int64(1)

function boundaryExtension_zeroPadding{T}(β::StridedVector{T},
                                          k::Int64)
    kmin = tilde_i0
    kmax = length(β) + kmin - 1
    
    if (k>=kmin)&&(k<=kmax)
        β[k]
    else
        T(0)
    end
end

function boundaryExtension_constant{T}(β::StridedVector{T},
                                       k::Int64)
    kmin = tilde_i0
    kmax = length(β) + kmin - 1

    if k<kmin
        β[kmin]
    elseif k<=kmax
        β[k]
    else
        β[kmax]
    end
end

function boundaryExtension_periodic{T}(β::StridedVector{T},
                                       k::Int64)
    kmin = tilde_i0
    kmax = length(β) + kmin - 1

    β[kmin+mod(k-kmin,1+kmax-kmin)]
end

function boundaryExtension_mirror{T}(β::StridedVector{T},
                                     k::Int64)
    kmin = tilde_i0
    kmax = length(β) + kmin - 1

    β[kmax-abs(kmax-kmin-mod(k-kmin,2*(kmax-kmin)))]
end

# For the user interface
#
boundaryExtension = 
    Dict(:ZeroPadding=>boundaryExtension_zeroPadding,
         :Constant=>boundaryExtension_constant,
         :Periodic=>boundaryExtension_periodic,
         :Mirror=>boundaryExtension_mirror)

function direct_conv!{T}(tilde_α::StridedVector{T},
                         Ωα::UnitRange,
                         λ::Int64,
                         β::StridedVector{T},
                         γ::StridedVector{T},
                         Ωγ::UnitRange,
                         LeftBoundary::Symbol,
                         RightBoundary::Symbol)
    # Sanity check
    @assert λ!=0
    @assert length(tilde_α)==length(Ωα)
    @assert (start(Ωγ)>=1)&&(last(Ωγ)<=length(γ))

    # Initialization
    Ωβ = UnitRange(1,length(β))
    tilde_Ωα = 1:length(Ωα)
    
    for k in Ωγ
        γ[k]=0 
    end

    rΩγ1=intersect(Ωγ,compute_Ωγ1(Ωα,λ,Ωβ))
    
    # rΩγ1 part: no boundary effect
    #
    β_offset = λ*(start(Ωα)-tilde_i0)
    @simd for k in rΩγ1
        for i in tilde_Ωα
            @inbounds γ[k]+=tilde_α[i]*β[k+λ*i+β_offset]
        end
    end

    # Left part
    #
    rΩγ1_left = relelativeComplement_left(Ωγ,rΩγ1)
    Φ_left = boundaryExtension[LeftBoundary]
    
    for k in rΩγ1_left
        for i in tilde_Ωα
            γ[k]+=tilde_α[i]*Φ_left(β,k+λ*i+β_offset)
        end
    end

    # Right part
    #
    rΩγ1_right = relelativeComplement_right(Ωγ,rΩγ1)
    Φ_right = boundaryExtension[RightBoundary]
    
    for k in rΩγ1_right
        for i in tilde_Ωα
            γ[k]+=tilde_α[i]*Φ_right(β,k+λ*i+β_offset)
        end
    end
end

# Some UI functions, γ inplace modification 
#
function direct_conv!{T}(tilde_α::StridedVector{T},
                         α_offset::Int64,
                         λ::Int64,

                         β::StridedVector{T},

                         γ::StridedVector{T},
                         Ωγ::UnitRange,
                         
                         LeftBoundary::Symbol,
                         RightBoundary::Symbol)

    Ωα = UnitRange(-α_offset,
                   length(tilde_α)-α_offset-1)
    
    direct_conv!(tilde_α,
                 Ωα,
                 λ,
                 
                 β,

                 γ,
                 Ωγ,

                 LeftBoundary,
                 RightBoundary)
end

# Some UI functions, allocates γ 
#
function direct_conv{T}(tilde_α::StridedVector{T},
                        α_offset::Int64,
                        λ::Int64,

                        β::StridedVector{T},

                        LeftBoundary::Symbol,
                        RightBoundary::Symbol)

    γ = Array{T,1}(length(β))
    
    direct_conv!(tilde_α,
                 α_offset,
                 λ,

                 β,

                 γ,
                 UnitRange(1,length(γ)),

                 LeftBoundary,
                 RightBoundary)

    γ
end

export direct_conv
export direct_conv!

end # module
