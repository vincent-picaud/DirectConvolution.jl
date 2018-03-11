# @testset "Savitzky-Golay definition" begin
#     sg=SavitzkyGolay_Filter(rand(11))
#     @test offset(sg) == 5
#     @test range(sg) == -5:5
#     @test length(sg) == 11
# end

@testset "Savitzky-Golay" begin

    m=SG_Filter(Float64,halfWidth=2,degree=0)

    @test filter(m,derivativeOrder=0) ≈ [1/5; 1/5; 1/5; 1/5; 1/5]

    m=SG_Filter(Float64,halfWidth=3,degree=2)

    @test filter(m,derivativeOrder=1) ≈ [-(3/28); -(1/14); -(1/28); 0;  (1/28); (1/14); (3/28)]
    @test filter(m,derivativeOrder=2) ≈ [5/42; 0; -(1/14); -(2/21); -(1/14); 0; 5/42]

    @test maxDerivativeOrder(m) == 2
    @test length(m) == 2*3+1
    @test polynomialOrder(m) == 2
end
