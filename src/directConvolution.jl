export directConv, directConv!
export BoundaryExtension, ZeroPaddingBE, ConstantBE, PeriodicBE, MirrorBE



# first index 
const tilde_i0 = Int(1)



#+BoundaryExtension
#
# Used for tag dispatching, parent of available boundary extensions
#
#!subtypes(BoundaryExtension)
#
abstract type BoundaryExtension end

#+BoundaryExtension
struct ZeroPaddingBE <: BoundaryExtension end
#+BoundaryExtension
struct ConstantBE <: BoundaryExtension end
#+BoundaryExtension
struct PeriodicBE <: BoundaryExtension end
#+BoundaryExtension
struct MirrorBE <: BoundaryExtension end



#+BoundaryExtension,Internal
#
# Range scaling
#
# *Caveat:*
# We do not use Julia =scale= function as it returns a step range:
#!r=6:8
#!-2*r
# What we need is:
#!scale(-2,r)
#
function scale(λ::Int,Ω::UnitRange{Int})
    ifelse(λ>0,
           UnitRange(λ*start(Ω),λ*last(Ω)),
           UnitRange(λ*last(Ω),λ*start(Ω)))
end

#+BoundaryExtension,Internal
#
# In
# $$
# \gamma[k]=\sum\limits_{i\in\Omega^\alpha}\alpha[i]\beta[k+\lambda i],\text{ with }\lambda\in\mathbb{Z}^*
# $$
# the computation of $\gamma[k],\ k\in\Omega^\gamma$ is splitted into two parts:  
#  - one part $\Omega^\gamma \cap \Omega^\gamma_1$ *free of boundary effect*,  
#  - one part $\Omega^\gamma \setminus \Omega^\gamma_1$ *that requires boundary extension* $\tilde{\beta}=\Phi(\beta,k)$
#
# *Example:*
#!DirectConvolution.compute_Ωγ1(-1:2,-2,1:20)
function compute_Ωγ1(Ωα::UnitRange{Int},
                     λ::Int,
                     Ωβ::UnitRange{Int})
    
    λΩα = scale(λ,Ωα)

    UnitRange(start(Ωβ)-start(λΩα),
              last(Ωβ)-last(λΩα))
end

#+BoundaryExtension,Internal
#
# Left relative complement
#
# $$
# (A\setminus B)_{\text{Left}}=[  l(A), \min{(u(A),l(B)-1)} ]
# $$
#
# *Example:*
#!DirectConvolution.relativeComplement_left(1:10,-5:5)
#
# $(A\setminus B)=\{6,7,8,9,10\}$ and the left part (elements that are
# $\in A$ but on the left side of $B$) is *empty*.
function relativeComplement_left(A::UnitRange{Int},
                                 B::UnitRange{Int})
    UnitRange(start(A),
              min(last(A),start(B)-1))
end

#+BoundaryExtension,Internal
#
# Left relative complement
#
# $$
# (A\setminus B)_{\text{Right}}=[ \max{(l(A),u(B)+1)}, u(A) ]
# $$
#
# *Example:*
#!DirectConvolution.relativeComplement_right(1:10,-5:5)
#
# $(A\setminus B)=\{6,7,8,9,10\}$ and the right part (elements that are
# $\in A$ but on the right side of $B$) are $\{6,7,8,9,10\}$
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

#+Convolution
# Computes a convolution.
#
# Inplace modification of γ
#
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

#+Convolution
# Computes a convolution.
#
# Takes a filter as input 
#
# Inplace modification of γ
#
function directConv!(α::LinearFilter{T},
                     λ::Int,

                     β::AbstractArray{T,1},

                     γ::AbstractArray{T,1},
                     Ωγ::UnitRange{Int},
                     
                     ::Type{LeftBE}=ZeroPaddingBE,
                     ::Type{RightBE}=ZeroPaddingBE;
                     
                     accumulate::Bool=false) where {T <: Number,
                                                    LeftBE <: BoundaryExtension,
                                                    RightBE <: BoundaryExtension}

    directConv!(fcoef(α),
                range(α),
                λ,
                
                β,

                γ,
                Ωγ,

                LeftBE,
                RightBE,
                
                accumulate=accumulate)
end




#+Convolution
#
# Computes a convolution.
#
# Returns γ, a created vector of length identical to β one.
#
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



#+API
#
# Computes a convolution.
#
# Returns γ, a created vector of length identical to β one.
#
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
