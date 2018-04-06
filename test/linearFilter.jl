@testset "LinearFilter_DefaultCentered" begin
    
    filter=DirectConvolution.LinearFilter_DefaultCentered(rand(11))

    @test offset(filter) == 5
    @test range(filter) == -5:5
    @test length(filter) == 11
end

@testset "LinearFilter_Default" begin

    v=rand(11)
    filter=DirectConvolution.LinearFilter_Default(v,4)

    @test offset(filter) == 4
    @test range(filter) == -4:6
    @test length(filter) == length(v)
    @test fcoef(filter) ≈ v
end
