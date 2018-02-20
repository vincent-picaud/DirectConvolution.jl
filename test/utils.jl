@testset "swap" begin

    a=Int(1)
    b=Int(2)

    @swap(a,b)

    @test a == 2
    @test b == 1

    a=rand(5)
    b=rand(8)

    @swap(a,b)

    @test length(a) == 8
    @test length(b) == 5

end;
