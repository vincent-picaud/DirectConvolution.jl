@testset "LinearFilter_DefaultCentered" begin
    
    filter=DirectConvolution.LinearFilter_DefaultCentered(rand(11))

    @test offset(filter) == 5
    @test range(filter) == -5:5
    @test length(filter) == 11
end

