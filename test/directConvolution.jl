@testset "Example α_offset" begin

    α0=LinearFilter(Float64[0,1,0],0)
    α1=LinearFilter(Float64[0,1,0],1)
    β=collect(Float64,1:6)
    γ1=directConv(α0,1,β,ZeroPaddingBE,ZeroPaddingBE)
    γ2=directConv(α1,1,β,ZeroPaddingBE,ZeroPaddingBE) 

    @test γ1 ≈ [2.0, 3.0, 4.0, 5.0, 6.0, 0.0]
    @test γ2 ≈ [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]

end;


@testset "Adjoint operator" begin

    α=LinearFilter(rand(4),2);
    β=rand(10);

    vβ=rand(length(β))
    d1=dot(directConv(α,-3,vβ,ZeroPaddingBE,ZeroPaddingBE),β)
    d2=dot(directConv(α,+3,β,ZeroPaddingBE,ZeroPaddingBE),vβ)

    
    @test isapprox(d1,d2)

    d1=dot(directConv(α,-3,vβ,PeriodicBE,PeriodicBE),β)
    d2=dot(directConv(α,+3,β,PeriodicBE,PeriodicBE),vβ)

    @test isapprox(d1,d2)

end;


@testset "Convolution commutativity" begin

    α=rand(4);
    αf=LinearFilter(α,0)
    β=rand(10);
    βf=LinearFilter(β,0)
    v1=zeros(20)
    v2=zeros(20)
    directConv!(αf,-1,
                β,v1,UnitRange(1,20),ZeroPaddingBE,ZeroPaddingBE)
    directConv!(βf,-1,
                α,v2,UnitRange(1,20),ZeroPaddingBE,ZeroPaddingBE)

    @test isapprox(v1,v2)

end;

@testset "Interval split" begin

    α=LinearFilter(rand(4),3)
    β=rand(10);

    γ=directConv(α,2,β,MirrorBE,PeriodicBE) # global computation
    Γ=zeros(length(γ))
    Ω1=UnitRange(1:3)
    Ω2=UnitRange(4:length(γ))
    directConv!(α,2,β,Γ,Ω1,MirrorBE,PeriodicBE) # compute on Ω1
    directConv!(α,2,β,Γ,Ω2,MirrorBE,PeriodicBE) # compute on Ω2

    @test isapprox(γ,Γ)

end;

@testset "2D convolution" begin
    β=rand(5,8)
    β_save=deepcopy(β)
    
    α_I=LinearFilter(Float64[0,2,0])
    α_J=LinearFilter(Float64[0,0,2,0,0])

    directConv2D!(α_I,1,α_J,-1,β)

    @test isapprox(β,4*β_save)
end;

@testset "2D crossCorrelation" begin
    β=rand(5,8)
    
    α_I=LinearFilter(Float64[0,2,0])
    α_J=LinearFilter(Float64[0,0,2,0,0])

    γ=directCrossCorrelation2D(α_I,α_J,β)

    @test isapprox(γ,4*β)
end;
