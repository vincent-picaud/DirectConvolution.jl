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



#+BoundaryExtension,Internal
#
#!r=-5:10
#!hcat(r,map(x->DirectConvolution.boundaryExtension([1:3;],x,ZeroPaddingBE),r))'
#
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

#+BoundaryExtension,Internal
#
#!r=-5:10
#!hcat(r,map(x->DirectConvolution.boundaryExtension([1:3;],x,ConstantBE),r))'
#
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

#+BoundaryExtension,Internal
#
#!r=-5:10
#!hcat(r,map(x->DirectConvolution.boundaryExtension([1:3;],x,PeriodicBE),r))'
#
function boundaryExtension(β::AbstractArray{T,1},
                           k::Int,
                           ::Type{PeriodicBE}) where {T <: Number}
    kmin = tilde_i0
    kmax = length(β) + kmin - 1

    β[kmin+mod(k-kmin,1+kmax-kmin)]
end

#+BoundaryExtension,Internal
#
#!r=-5:10
#!hcat(r,map(x->DirectConvolution.boundaryExtension([1:3;],x,MirrorBE),r))'
#
function boundaryExtension(β::AbstractArray{T,1},
                           k::Int,
                           ::Type{MirrorBE}) where {T <: Number}
    kmin = tilde_i0
    kmax = length(β) + kmin - 1

    β[kmax-abs(kmax-kmin-mod(k-kmin,2*(kmax-kmin)))]
end




#+Convolution,Internal
function directConv!(tilde_α::AbstractArray{T,1},
                     α_offset::Int,
                     λ::Int,
                     β::AbstractArray{T,1},
                     γ::AbstractArray{T,1},
                     Ωγ::UnitRange{Int},
                     ::Type{LeftBE}=ZeroPaddingBE,
                     ::Type{RightBE}=ZeroPaddingBE;
                     accumulate::Bool=false)::Void where {T <: Number,
                                                          LeftBE <: BoundaryExtension,
                                                          RightBE <: BoundaryExtension}
    # Sanity check
    @assert λ!=0
    @assert (start(Ωγ)>=1)&&(last(Ωγ)<=length(γ))

    # Initialization
    const Ωα = filter_range(length(tilde_α),α_offset)
    const Ωβ = UnitRange(1,length(β))
    const tilde_Ωα = 1:length(Ωα)

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

    nothing
end

#+Convolution L:directConv_details
# Computes a convolution.
#
# Inplace modification of $\gamma[k], k\in\Omega_\gamma$.
# $$
# \gamma[k]=\sum\limits_{i\in\Omega^\alpha}\alpha[i]\beta[k+\lambda i],\text{ with }\lambda\in\mathbb{Z}^*
# $$
# If $k\notin \Omega_\gamma$, $\gamma[k]$ is unmodified.
#
# If *accumulate=false* then an erasing step $\gamma[k]=0,
# k\in\Omega_\gamma$ is performed before computation.
#
# If $\lambda=-1$ you compute a convolution, if $\lambda=+1$ you
# compute a cross-correlation.
#
# *Example:*
#!β=[1:15;];
#!γ=ones(Int,15);
#!α=LinearFilter([0,0,1],0);
#!directConv!(α,1,β,γ,5:10);
#!hcat([1:length(γ);],γ)'
#
function directConv!(α::LinearFilter{T},
                     λ::Int,

                     β::AbstractArray{T,1},

                     γ::AbstractArray{T,1},
                     Ωγ::UnitRange{Int},
                     
                     ::Type{LeftBE}=ZeroPaddingBE,
                     ::Type{RightBE}=ZeroPaddingBE;
                     
                     accumulate::Bool=false)::Void where {T <: Number,
                                                          LeftBE <: BoundaryExtension,
                                                          RightBE <: BoundaryExtension}

    directConv!(fcoef(α),
                offset(α),
                λ,
                
                β,

                γ,
                Ωγ,

                LeftBE,
                RightBE,
                
                accumulate=accumulate)

    nothing
end




#+Convolution
#
# Computes a convolution.
#
# Convenience function that allocate $\gamma$ and compute all its
# component using [[directConv_details][]]
#
# *Returns:* $\gamma$ a created vector of length identical to the $\beta$ one.
#
# *Example:*
#!β=[1:15;];
#!γ=ones(Int,15);
#!α=LinearFilter([0,0,1],0);
#!γ=directConv(α,1,β);
#!hcat([1:length(γ);],γ)'
#
function directConv(α::LinearFilter{T},

                    λ::Int64,

                    β::AbstractArray{T,1},

                    ::Type{LeftBE}=ZeroPaddingBE,
                    ::Type{RightBE}=ZeroPaddingBE) where {T <: Number,
                                                          LeftBE <: BoundaryExtension,
                                                          RightBE <: BoundaryExtension}
    γ = Array{T,1}(length(β))
    
    directConv!(α,
                λ,

                β,

                γ,
                UnitRange(1,length(γ)),

                LeftBE,
                RightBE,
                
                accumulate=false)

    return γ
end



#+Convolution
#
# Computes a convolution.
#
# This is a convenience function where $\lambda=-1$
#
# *Returns:* $\gamma$ a created vector of length identical to the $\beta$ one.
#
function directConv(α::LinearFilter{T},
                    β::AbstractArray{T,1},

                    ::Type{LeftBE}=ZeroPaddingBE,
                    ::Type{RightBE}=ZeroPaddingBE) where {T <: Number,
                                                          LeftBE <: BoundaryExtension,
                                                          RightBE <: BoundaryExtension}

    return directConv(α,-1,β,LeftBE,RightBE)
end

#+Convolution
#
# Computes a cross-correlation 
#
# This is a convenience function where $\lambda=+1$
#
# *Returns:* $\gamma$ a created vector of length identical to the $\beta$ one.
#
function directCrossCorrelation(α::LinearFilter{T},
                                β::AbstractArray{T,1},

                                ::Type{LeftBE}=ZeroPaddingBE,
                                ::Type{RightBE}=ZeroPaddingBE) where {T <: Number,
                                                                      LeftBE <: BoundaryExtension,
                                                                      RightBE <: BoundaryExtension}

    return directConv(α,+1,β,LeftBE,RightBE)
end
