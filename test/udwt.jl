@testset "UDWT_Haar" begin

    const haar_udwt = UDWT_Filter_Haar{Float64}()

    @test ϕ_filter(haar_udwt) ≈ [sqrt(2.)*1/2, sqrt(2.)*1/2]
    @test tildeϕ_filter(haar_udwt) ≈ [sqrt(2.)*1/2, sqrt(2.)*1/2]
    @test ϕ_offset(haar_udwt) == 0
end
