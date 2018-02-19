@testset "Savitzky-Golay" begin

    m=SG_Filter(Float64,halfWidth=2,degree=0)

    @test m ≈ [1/5; 1/5; 1/5; 1/5; 1/5]

    m=SG_Filter(Float64,halfWidth=3,degree=2)

    @test m ≈ [-(2/21) -(3/28) 5/42; 1/7 -(1/14) 0; 2/ 7 -(1/28) -(1/14); 1/3 0 -(2/21); 2/7 1/28 -(1/14); 1/7 1/14 0; -(2/21) 3/28 5/42]

end
