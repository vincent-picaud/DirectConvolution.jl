@testset "Haar" begin

    haar_udwt = UDWT_Filter_Haar{Float64}()

    @test ϕ_filter(haar_udwt) ≈ [1/2, 1/2]
    @test tildeϕ_filter(haar_udwt) ≈ [1/2, 1/2]

    @test ψ_filter(haar_udwt) ≈ [-1/2, 1/2]
    @test tildeψ_filter(haar_udwt) ≈ [-1/2, 1/2]

end

@testset "Starck2" begin

    starck2_udwt = UDWT_Filter_Starck2{Float64}()

    @test fcoef(tildeϕ_filter(starck2_udwt)) ≈ [1]
end

@testset "UDWT Transform" begin

    signal = rand(20)

    for filter in [UDWT_Filter_Haar{Float64}()
                   UDWT_Filter_Starck2{Float64}()]

        s = 4
        m = udwt(signal,filter,scale=s)
        
        @test size(m.W) == (length(signal),s)
        @test size(m.V) == (length(signal),)
        @test scale(m) == s
        
        signal_from_inv = inverse_udwt(m)
        
        @test signal ≈ signal_from_inv
    end
end 
