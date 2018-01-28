using DirectConvolution
using Base.Test


@testset "Adjoint operator" begin

    α=rand(4);
    β=rand(10);

    vβ=rand(length(β))
    d1=dot(direct_conv(α,2,-3,vβ,:ZeroPadding,:ZeroPadding),β)
    d2=dot(direct_conv(α,2,+3,β,:ZeroPadding,:ZeroPadding),vβ)

    
    @test isapprox(d1,d2)

    d1=dot(direct_conv(α,-1,-3,vβ,:Periodic,:Periodic),β)
    d2=dot(direct_conv(α,-1,+3,β,:Periodic,:Periodic),vβ)

    @test isapprox(d1,d2)

end;


@testset "Convolution commutativity" begin

    α=rand(4);
    β=rand(10);

    v1=zeros(20)
    v2=zeros(20)
    direct_conv!(α,0,-1,
                 β,v1,UnitRange(1,20),:ZeroPadding,:ZeroPadding)
    direct_conv!(β,0,-1,
                 α,v2,UnitRange(1,20),:ZeroPadding,:ZeroPadding)

    @test isapprox(v1,v2)

end;

@testset "Interval split" begin

    α=rand(4);
    β=rand(10);

    γ=direct_conv(α,3,2,β,:Mirror,:Periodic) # global computation
    Γ=zeros(length(γ))
    Ω1=UnitRange(1:3)
    Ω2=UnitRange(4:length(γ))
    direct_conv!(α,3,2,β,Γ,Ω1,:Mirror,:Periodic) # compute on Ω1
    direct_conv!(α,3,2,β,Γ,Ω2,:Mirror,:Periodic) # compute on Ω2

    @test isapprox(γ,Γ)

end;
