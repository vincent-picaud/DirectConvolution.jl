export directConv, directConv!
export BoundaryExtension, ZeroPaddingBE, ConstantBE, PeriodicBE, MirrorBE



# first index 
const tilde_i0 = Int(1)



# [BEGIN_BoundaryExtension]
abstract type BoundaryExtension end

struct ZeroPaddingBE <: BoundaryExtension end
struct ConstantBE <: BoundaryExtension end
struct PeriodicBE <: BoundaryExtension end
struct MirrorBE <: BoundaryExtension end
# [END_BoundaryExtension]



# CAVEAT: do not use builtin 2*UnitRange as it returns a StepRange.
# We want -2*(6:8) -> -16:-12 and not -12:-2:-16
#
function scale(λ::Int,Ω::UnitRange{Int})
    ifelse(λ>0,
           UnitRange(λ*start(Ω),λ*last(Ω)),
           UnitRange(λ*last(Ω),λ*start(Ω)))
end

function compute_Ωγ1(Ωα::UnitRange{Int},
                     λ::Int,
                     Ωβ::UnitRange{Int})
    
    λΩα = scale(λ,Ωα)

    UnitRange(start(Ωβ)-start(λΩα),
              last(Ωβ)-last(λΩα))
end

# Left & Right relative complements A\B
#
function relativeComplement_left(A::UnitRange{Int},
                                 B::UnitRange{Int})
    UnitRange(start(A),
              min(last(A),start(B)-1))
end

function relativeComplement_right(A::UnitRange{Int},
                                  B::UnitRange{Int})
    UnitRange(max(start(A),last(B)+1),
              last(A))
end



function boundaryExtension(β::AbstractArray{T,1},
                           k::Int,
                           ::Type{ZeroPaddingBE}) where {T <: Number}
    kmin = tilde_i0
    kmax = length(β) + kmin - 1
    
    if (k>=kmin)&&(k<=kmax)
        β[k]
    else
        T(0)
    end
end

function boundaryExtension(β::AbstractArray{T,1},
                           k::Int,
                           ::Type{ConstantBE}) where {T <: Number}
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

function boundaryExtension(β::AbstractArray{T,1},
                           k::Int,
                           ::Type{PeriodicBE}) where {T <: Number}
    kmin = tilde_i0
    kmax = length(β) + kmin - 1

    β[kmin+mod(k-kmin,1+kmax-kmin)]
end

function boundaryExtension(β::AbstractArray{T,1},
                           k::Int,
                           ::Type{MirrorBE}) where {T <: Number}
    kmin = tilde_i0
    kmax = length(β) + kmin - 1

    β[kmax-abs(kmax-kmin-mod(k-kmin,2*(kmax-kmin)))]
end




function directConv!(tilde_α::AbstractArray{T,1},
                     Ωα::UnitRange{Int},
                     λ::Int,
                     β::AbstractArray{T,1},
                     γ::AbstractArray{T,1},
                     Ωγ::UnitRange{Int},
                     ::Type{LeftBE}=ZeroPaddingBE,
                     ::Type{RightBE}=ZeroPaddingBE;
                     accumulate::Bool=false) where {T <: Number,
                                                    LeftBE <: BoundaryExtension,
                                                    RightBE <: BoundaryExtension}
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
    
    for k in rΩγ1_left
        for i in tilde_Ωα
            γ[k]+=tilde_α[i]*boundaryExtension(β,k+λ*i+β_offset,LeftBE)
        end
    end

    # Right part
    #
    rΩγ1_right = relativeComplement_right(Ωγ,rΩγ1)
    
    for k in rΩγ1_right
        for i in tilde_Ωα
            γ[k]+=tilde_α[i]*boundaryExtension(β,k+λ*i+β_offset,RightBE)
        end
    end
end

doc"""
             directConv!(tilde_α::AbstractArray{T,1},
                         α_offset::Int,
                         λ::Int,

                         β::AbstractArray{T,1},

                         γ::AbstractArray{T,1},
                         Ωγ::UnitRange{Int},
                         
                         ::Type{LeftBE}=ZeroPaddingBE,
                         ::Type{RightBE}=ZeroPaddingBE;
                         
                         accumulate::Bool=false) where {T <: Number,
                                                        LeftBE <: BoundaryExtension,
                                                        RightBE <: BoundaryExtension}

    Computes a convolution.

    Inplace modification of γ
        """
# [BEGIN_directConv!]
function directConv!(tilde_α::AbstractArray{T,1},
                     α_offset::Int,
                     λ::Int,

                     β::AbstractArray{T,1},

                     γ::AbstractArray{T,1},
                     Ωγ::UnitRange{Int},
                     
                     ::Type{LeftBE}=ZeroPaddingBE,
                     ::Type{RightBE}=ZeroPaddingBE;
                     
                     accumulate::Bool=false) where {T <: Number,
                                                    LeftBE <: BoundaryExtension,
                                                    RightBE <: BoundaryExtension}
    # [END_directConv!]
    Ωα = UnitRange(-α_offset,
                   length(tilde_α)-α_offset-1)
    
    directConv!(tilde_α,
                Ωα,
                λ,
                
                β,

                γ,
                Ωγ,

                LeftBE,
                RightBE,
                
                accumulate=accumulate)
end

# Some UI functions, allocates γ 
#
doc"""
            directConv(tilde_α::AbstractArray{T,1},
                        α_offset::Int64,
                        λ::Int64,

                        β::AbstractArray{T,1},

                        ::Type{LeftBE}=ZeroPaddingBE,
                        ::Type{RightBE}=ZeroPaddingBE) where {T <: Number,
                                                              LeftBE <: BoundaryExtension,
                                                              RightBE <: BoundaryExtension}

    Computes a convolution.

    Returns γ, a created vector of length identical to β one.
    """
# [BEGIN_directConv]
function directConv(tilde_α::AbstractArray{T,1},
                    α_offset::Int64,
                    λ::Int64,

                    β::AbstractArray{T,1},

                    ::Type{LeftBE}=ZeroPaddingBE,
                    ::Type{RightBE}=ZeroPaddingBE) where {T <: Number,
                                                          LeftBE <: BoundaryExtension,
                                                          RightBE <: BoundaryExtension}
    # [END_directConv]
    γ = Array{T,1}(length(β))
    
    directConv!(tilde_α,
                α_offset,
                λ,

                β,

                γ,
                UnitRange(1,length(γ)),

                LeftBE,
                RightBE,
                
                accumulate=false)

    γ
end




function directConv(α::LinearFilter{T},
                    β::AbstractArray{T,1},

                    ::Type{LeftBE}=ZeroPaddingBE,
                    ::Type{RightBE}=ZeroPaddingBE) where {T <: Number,
                                                          LeftBE <: BoundaryExtension,
                                                          RightBE <: BoundaryExtension}

    return directConv(fcoef(α),
                      offset(α),
                      -1,
                      β,
                      LeftBE,
                      RightBE)
end
