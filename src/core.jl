export directConv, directConv!, directConv2D!, directCrossCorrelation,directCrossCorrelation2D
export BoundaryExtension, ZeroPaddingBE, ConstantBE, PeriodicBE, MirrorBE
export boundaryExtension

# first index 
const tilde_i0 = Int(1)

# ================================================================
# Used for tag dispatching, parent of available boundary extensions
# ================================================================

#+BoundaryExtension
#
#
#!subtypes(BoundaryExtension)
#
abstract type BoundaryExtension end

"""
    struct ZeroPaddingBE 

A type used to tag zero padding extension
"""
struct ZeroPaddingBE <: BoundaryExtension end

"""
    struct ConstantBE

A type used to tag constant constant extension
"""
struct ConstantBE <: BoundaryExtension end

"""
    struct PeriodicBE

A type used to tag periodic extension
"""
struct PeriodicBE <: BoundaryExtension end

"""
    struct MirrorBE

A type used to tag mirror extension
"""
struct MirrorBE <: BoundaryExtension end


"""
    scale(λ::Int,Ω::UnitRange{Int})

Range scaling.

**Caveat:**

We do not use Julia =*= operator as it returns a step range:
```jldoctest
julia> r=6:8
6:8

julia> -2*r
-12:-2:-16
```

What we need is:

```jldoctest
julia> r=6:8
6:8

julia> scale(-2,r)
-16:-12
```
"""
function scale(λ::Int,Ω::UnitRange{Int})
    ifelse(λ>0,
           UnitRange(λ*first(Ω),λ*last(Ω)),
           UnitRange(λ*last(Ω),λ*first(Ω)))
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

    UnitRange(first(Ωβ)-first(λΩα),
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
    UnitRange(first(A),
              min(last(A),first(B)-1))
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
# $\in A$ but on the right side of $B$) is $\{6,7,8,9,10\}$
function relativeComplement_right(A::UnitRange{Int},
                                  B::UnitRange{Int})
    UnitRange(max(first(A),last(B)+1),
              last(A))
end

# ================================================================

"""
    boundaryExtension(β::AbstractArray{T,1},
                      k::Int,
                      ::Type{BOUNDARY_EXT_TYPE})

Computes extended boundary value `β[k]` given boundary extension type
`BOUNDARY_EXT_TYPE`

Available `BOUNDARY_EXT_TYPE` are:
* `ZeroPaddingBE`: zero padding
* `ConstantBE`: constant boundary extension padding
* `PeriodicBE`: periodic boundary extension padding
* `MirrorBE`: mirror symmetry boundary extension padding

The routine is robust in the sens that there is no restriction on `k`
value.

```jldoctest
julia> dom = [-5:10;];

julia> hcat(dom,map(x->boundaryExtension([1; 2; 3],x,ZeroPaddingBE),dom))'
2×16 adjoint(::Matrix{Int64}) with eltype Int64:
 -5  -4  -3  -2  -1  0  1  2  3  4  5  6  7  8  9  10
  0   0   0   0   0  0  1  2  3  0  0  0  0  0  0   0

julia> hcat(dom,map(x->boundaryExtension([1; 2; 3],x,ConstantBE),dom))'
2×16 adjoint(::Matrix{Int64}) with eltype Int64:
 -5  -4  -3  -2  -1  0  1  2  3  4  5  6  7  8  9  10
  1   1   1   1   1  1  1  2  3  3  3  3  3  3  3   3

julia> hcat(dom,map(x->boundaryExtension([1; 2; 3],x,PeriodicBE),dom))'
2×16 adjoint(::Matrix{Int64}) with eltype Int64:
 -5  -4  -3  -2  -1  0  1  2  3  4  5  6  7  8  9  10
  1   2   3   1   2  3  1  2  3  1  2  3  1  2  3   1

julia> hcat(dom,map(x->boundaryExtension([1; 2; 3],x,MirrorBE),dom))'
2×16 adjoint(::Matrix{Int64}) with eltype Int64:
 -5  -4  -3  -2  -1  0  1  2  3  4  5  6  7  8  9  10
  3   2   1   2   3  2  1  2  3  2  1  2  3  2  1   2

```

"""
function boundaryExtension end

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


# ================================================================

#+Convolution,Internal
function directConv!(tilde_α::AbstractArray{T,1},
                     α_offset::Int,
                     λ::Int,
                     β::AbstractArray{T,1},
                     γ::AbstractArray{T,1},
                     Ωγ::UnitRange{Int},
                     ::Type{LeftBE}=ZeroPaddingBE,
                     ::Type{RightBE}=ZeroPaddingBE;
                     accumulate::Bool=false)::Nothing where {T <: Number,
                                                             LeftBE <: BoundaryExtension,
                                                             RightBE <: BoundaryExtension}
    # Sanity check
    @assert λ!=0
    @assert (first(Ωγ)>=1)&&(last(Ωγ)<=length(γ))

    # Initialization
    Ωα = filter_range(length(tilde_α),α_offset)
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
    β_offset = λ*(first(Ωα)-tilde_i0)
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

# """
#     directConv!

# Computes a convolution.

# Inplace modification of ``\\gamma[k], k\\in\\Omega_\\gamma``

# ```math 
# \gamma[k]=\sum\limits_{i\in\Omega^\alpha}\alpha[i]\beta[k+\lambda i],\text{ with }\lambda\in\mathbb{Z}^*
# ```

# If ``k\\notin \\Omega_\\gamma``, ``\\gamma[k]`` is unmodified.

# If *accumulate=false* then an erasing step ``\\gamma[k]=0, k\\in\\Omega_\\gamma`` is performed before computation.

# If ``\\lambda=-1`` you compute a convolution, if ``\\lambda=+1`` you
# compute a cross-correlation.

# **Example:**

# ```@jldoctest

# julia> β=[1:15;]

# julia> γ=ones(Int,15)

# julia> α=LinearFilter([0,0,1],0)

# julia> directConv!(α,1,β,γ,5:10)

# julia> hcat([1:length(γ);],γ)

# ```

# """

"""
    directConv!

Computes a convolution.
```math 
\\gamma[k]=\\sum\\limits_{i\\in\\Omega^\\alpha}\\alpha[i]\\beta[k+\\lambda i]
```

The following example shows how to apply inplace the `[0 0 1]` filter on `γ[5:10]` 
```jldoctest
julia> β=[1:15;];

julia> γ=ones(Int,15);

julia> α=LinearFilter([0,0,1],0);

julia> directConv!(α,1,β,γ,5:10)

julia> hcat([1:length(γ);],γ)
15×2 Matrix{Int64}:
  1   1
  2   1
  3   1
  4   1
  5   7
  6   8
  7   9
  8  10
  9  11
 10  12
 11   1
 12   1
 13   1
 14   1
 15   1

```

"""
function directConv!(α::LinearFilter{T},
                     λ::Int,

                     β::AbstractArray{T,1},

                     γ::AbstractArray{T,1},
                     Ωγ::UnitRange{Int},
                     
                     ::Type{LeftBE}=ZeroPaddingBE,
                     ::Type{RightBE}=ZeroPaddingBE;
                     
                     accumulate::Bool=false)::Nothing where {T <: Number,
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
    γ = Array{T,1}(undef,length(β))
    
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


# 2D


# +Convolution L:directConv2D_inplace
# Computes a 2D (separable) convolution.
#
# For general information about parameters, see [[directConv_details][]]
#
# α_I must be interpreted as filter for *running index I*
#
# CAVEAT: the result overwrites β
#
# TODO: @parallel
function directConv2D!(α_I::LinearFilter{T},
                       λ_I::Int,
                       α_J::LinearFilter{T},
                       λ_J::Int,
                       
                       β::AbstractArray{T,2},
                       
                       min_I_BE::Type{<:BoundaryExtension}=ZeroPaddingBE,
                       max_I_BE::Type{<:BoundaryExtension}=ZeroPaddingBE,
                       min_J_BE::Type{<:BoundaryExtension}=ZeroPaddingBE,
                       max_J_BE::Type{<:BoundaryExtension}=ZeroPaddingBE)::Nothing where {T<:Number}
    
    γ=similar(β)

    (n,m)=size(β)
    α_I_coef=fcoef(α_I)
    α_I_offset=offset(α_I)
    α_J_coef=fcoef(α_J)
    α_J_offset=offset(α_J)
    Ωγ_I = 1:n
    Ωγ_J = 1:m
    
    # i running (for filter)
    for j in 1:m

        directConv!(α_I_coef,
                    α_I_offset,
                    λ_I,
                    
                    view(β,:,j),
                    
                    view(γ,:,j), 
                    Ωγ_I,
                    
                    min_I_BE,
                    max_I_BE,
                    
                    accumulate=false)
    end
    
    # j running (for filter)
    for i in 1:n

        directConv!(α_J_coef,
                    α_J_offset,
                    λ_J,
                    
                    view(γ,i,:),
                    
                    view(β,i,:), 
                    Ωγ_J,
                    
                    min_J_BE,
                    max_J_BE,
                    
                    accumulate=false)
    end 

    nothing
end

# +Convolution
# Computes a 2D cross-correlation
#
# This is a wrapper that calls [[directConv2D_inplace][]]
#
# *Note:* β is not modified, instead the function returns the result.
#
function directCrossCorrelation2D(α_I::LinearFilter{T},
                                  α_J::LinearFilter{T},
                                  
                                  β::AbstractArray{T,2},
                                  
                                  min_I_BE::Type{<:BoundaryExtension}=ZeroPaddingBE,
                                  max_I_BE::Type{<:BoundaryExtension}=ZeroPaddingBE,
                                  min_J_BE::Type{<:BoundaryExtension}=ZeroPaddingBE,
                                  max_J_BE::Type{<:BoundaryExtension}=ZeroPaddingBE)::Array{T,2} where {T<:Number}

    γ=similar(β)
    γ.=β

    directConv2D!(α_I,+1,α_J,+1,γ,
                  min_I_BE,
                  max_I_BE,
                  min_J_BE,
                  max_J_BE)

    return γ
end


