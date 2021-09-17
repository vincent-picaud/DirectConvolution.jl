t#
# Benchmark example
#
using DirectConvolution
using DSP, BenchmarkTools,LinearAlgebra

# function bench_directconv(filter,signal)
#     wrapped_filter = LinearFilter(filter,0)
#     convolved = directConv(wrapped_filter,signal)

#     convolved
# end
function bench_directconv(filter,signal)
    convolved = similar(signal)
    n=length(convolved)
    
    directConv!(filter,0,-1,signal,convolved,1:n)

    convolved
end

function bench_dsp(filter,signal)
    convolved = conv(filter,signal)
    
    n=length(signal)
    convolved[1:n]
end
# function bench_check(;filter_length,signal_length)
#     r1 = 
# end


function bench(;filter_length,signal_length)
    @assert filter_length>0 && signal_length>0

    filter = rand(filter_length)
    signal = rand(signal_length)

    
    t1 = @benchmark bench_directconv($filter,$signal)
    t2 = @benchmark bench_dsp($filter,$signal)

    t1_min=minimum(t1.times)
    t2_min=minimum(t2.times)

    println()
    println("filter = $filter_length, signal = $signal_length")
    println("DirectConvolution: $(t1_min)μs, $(t1.allocs) allocs")
    println("DSP              : $(t2_min)μs, $(t2.allocs) allocs")
    println("Ratio ",t2_min/t1_min)
end

t = bench(filter_length=5,signal_length=10)
t = bench(filter_length=5,signal_length=1000)
t = bench(filter_length=5,signal_length=10000)

t = bench(filter_length=15,signal_length=10)
t = bench(filter_length=15,signal_length=1000)
t = bench(filter_length=15,signal_length=10000)


t = bench(filter_length=50,signal_length=1000)
t = bench(filter_length=500,signal_length=1000)
