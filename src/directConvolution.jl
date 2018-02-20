export directConv, directConv!

# CAVEAT: do not use builtin 2*UnitRange as it returns a StepRange.
# We want -2*(6:8) -> -16:-12 and not -12:-2:-16
#
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
function relativeComplement_left(A::UnitRange,
                                   B::UnitRange)
    UnitRange(start(A),
              min(last(A),start(B)-1))
end

function relativeComplement_right(A::UnitRange,
                                    B::UnitRange)
    UnitRange(max(start(A),last(B)+1),
              last(A))
end

const tilde_i0 = Int64(1)

function boundaryExtension_zeroPadding(β::AbstractArray{T,1},
                                       k::Int64) where T
    kmin = tilde_i0
    kmax = length(β) + kmin - 1
    
    if (k>=kmin)&&(k<=kmax)
        β[k]
    else
        T(0)
    end
end

function boundaryExtension_constant(β::AbstractArray{T,1},
                                    k::Int64) where T
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

function boundaryExtension_periodic(β::AbstractArray{T,1},
                                    k::Int64)  where T
    kmin = tilde_i0
    kmax = length(β) + kmin - 1

    β[kmin+mod(k-kmin,1+kmax-kmin)]
end

function boundaryExtension_mirror(β::AbstractArray{T,1},
                                  k::Int64) where T
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

function directConv!(tilde_α::AbstractArray{T,1},
                     Ωα::UnitRange,
                     λ::Int64,
                     β::AbstractArray{T,1},
                     γ::AbstractArray{T,1},
                     Ωγ::UnitRange,
                     LeftBoundary::Symbol,
                     RightBoundary::Symbol;
                     accumulate::Bool=false) where T
    # Sanity check
    @assert λ!=0
    @assert length(tilde_α)==length(Ωα)
    @assert (start(Ωγ)>=1)&&(last(Ωγ)<=length(γ))

    # Initialization
    Ωβ = UnitRange(1,length(β))
    tilde_Ωα = 1:length(Ωα)

    if !accumulate
        for k in Ωγ
            γ[k]=0 
        end
    end 

    rΩγ1=intersect(Ωγ,compute_Ωγ1(Ωα,λ,Ωβ))
    
    # rΩγ1 part: no boundary effect
    #
    β_offset = λ*(start(Ωα)-tilde_i0)
    for k in rΩγ1
        @simd for i in tilde_Ωα
            @inbounds γ[k]+=tilde_α[i]*β[k+λ*i+β_offset]
        end
    end
    
    # Left part
    #
    rΩγ1_left = relativeComplement_left(Ωγ,rΩγ1)
    Φ_left = boundaryExtension[LeftBoundary]
    
    for k in rΩγ1_left
        for i in tilde_Ωα
            γ[k]+=tilde_α[i]*Φ_left(β,k+λ*i+β_offset)
        end
    end

    # Right part
    #
    rΩγ1_right = relativeComplement_right(Ωγ,rΩγ1)
    Φ_right = boundaryExtension[RightBoundary]
    
    for k in rΩγ1_right
        for i in tilde_Ωα
            γ[k]+=tilde_α[i]*Φ_right(β,k+λ*i+β_offset)
        end
    end
end

# Some UI functions, γ inplace modification 
#
function directConv!(tilde_α::AbstractArray{T,1},
                     α_offset::Int64,
                     λ::Int64,

                     β::AbstractArray{T,1},

                     γ::AbstractArray{T,1},
                     Ωγ::UnitRange,
                     
                     LeftBoundary::Symbol,
                     RightBoundary::Symbol;
                     accumulate::Bool=false) where T

    Ωα = UnitRange(-α_offset,
                   length(tilde_α)-α_offset-1)
    
    directConv!(tilde_α,
                Ωα,
                λ,
                
                β,

                γ,
                Ωγ,

                LeftBoundary,
                RightBoundary,
                accumulate=accumulate)
end

# Some UI functions, allocates γ 
#
doc"""
    directConv(tilde_α::AbstractArray{T,1},
                α_offset::Int64,
                    λ::Int64,

                    β::AbstractArray{T,1},

                    LeftBoundary::Symbol,
                    RightBoundary::Symbol)

Compute convolution.

Return γ, a created vector of length identical to β one.
"""
function directConv(tilde_α::AbstractArray{T,1},
                    α_offset::Int64,
                    λ::Int64,

                    β::AbstractArray{T,1},

                    LeftBoundary::Symbol,
                    RightBoundary::Symbol) where T

    γ = Array{T,1}(length(β))
    
    directConv!(tilde_α,
                α_offset,
                λ,

                β,

                γ,
                UnitRange(1,length(γ)),

                LeftBoundary,
                RightBoundary,
                accumulate=false)

    γ
end

