@testset "Example α_offset" begin

    α=Float64[0,1,0]
    β=collect(Float64,1:6)
    γ1=directConv(α,0,1,β,:ZeroPadding,:ZeroPadding)
    γ2=directConv(α,1,1,β,:ZeroPadding,:ZeroPadding) 

    @test γ1 ≈ [2.0, 3.0, 4.0, 5.0, 6.0, 0.0]
    @test γ2 ≈ [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]

end;


@testset "Adjoint operator" begin

    α=rand(4);
    β=rand(10);

    vβ=rand(length(β))
    d1=dot(directConv(α,2,-3,vβ,:ZeroPadding,:ZeroPadding),β)
    d2=dot(directConv(α,2,+3,β,:ZeroPadding,:ZeroPadding),vβ)

    
    @test isapprox(d1,d2)

    d1=dot(directConv(α,-1,-3,vβ,:Periodic,:Periodic),β)
    d2=dot(directConv(α,-1,+3,β,:Periodic,:Periodic),vβ)

    @test isapprox(d1,d2)

end;


@testset "Convolution commutativity" begin

    α=rand(4);
    β=rand(10);

    v1=zeros(20)
    v2=zeros(20)
    directConv!(α,0,-1,
                β,v1,UnitRange(1,20),:ZeroPadding,:ZeroPadding)
    directConv!(β,0,-1,
                α,v2,UnitRange(1,20),:ZeroPadding,:ZeroPadding)

    @test isapprox(v1,v2)

end;

@testset "Interval split" begin

    α=rand(4);
    β=rand(10);

    γ=directConv(α,3,2,β,:Mirror,:Periodic) # global computation
    Γ=zeros(length(γ))
    Ω1=UnitRange(1:3)
    Ω2=UnitRange(4:length(γ))
    directConv!(α,3,2,β,Γ,Ω1,:Mirror,:Periodic) # compute on Ω1
    directConv!(α,3,2,β,Γ,Ω2,:Mirror,:Periodic) # compute on Ω2

    @test isapprox(γ,Γ)

end;
