@testset "Haar" begin

    const haar_udwt = UDWT_Filter_Haar{Float64}()

    @test ϕ_filter(haar_udwt) ≈ [sqrt(2.)*1/2, sqrt(2.)*1/2]
    @test tildeϕ_filter(haar_udwt) ≈ [sqrt(2.)*1/2, sqrt(2.)*1/2]
    @test ϕ_offset(haar_udwt) == 0

    @test ψ_filter(haar_udwt) ≈ [-sqrt(2.)*1/2, sqrt(2.)*1/2]
    @test tildeψ_filter(haar_udwt) ≈ [-sqrt(2.)*1/2, sqrt(2.)*1/2]
    @test ψ_offset(haar_udwt) == 0

end

@testset "Starck2" begin

    const starck2_udwt = UDWT_Filter_Starck2{Float64}()

    @test tildeϕ_filter(starck2_udwt) ≈ [sqrt(2.)*1]
    @test tildeϕ_offset(starck2_udwt) == 0

end

@testset "UDWT Transform" begin

    const signal = rand(10)
    const haar_udwt = UDWT_Filter_Haar{Float64}()

    m = udwt(signal,haar_udwt,scale=2)

    @test size(m.W) == (2,length(signal))
    @test size(m.V) == (length(signal),)
    @test scale(m) == 2

    signal_from_inv = inverse_udwt(m)

    @test signal ≈ signal_from_inv
end
