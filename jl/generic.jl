#!/usr/bin/env julia
using Pkg
Pkg.add("BenchmarkTools")
using BenchmarkTools

struct Point{T<:AbstractFloat}
    x::T
    f::T
end

function neumaier_sum(x::T, sum::T, comp::T)::Tuple{T, T} where {T<:AbstractFloat }
    t=sum+x
    if abs(sum)>=abs(x)
        comp+=(sum-t)+x
    else
        comp+=(x-t)+sum
    end
    sum=t
    (sum, comp)
end

function integrate(func::Function, ticks::Array{T,1}, eps1::T)::T where {T<:AbstractFloat }
    if length(ticks)<2
        return 0.0
    end
    #points::Array{Point{T}, 1}=[Point(x, func(x)) for x in ticks]
    points=map(x->Point(x, func(x)), ticks)
    full_width=last(ticks)-first(ticks)
    eps=eps1*4.0/full_width
    #eps=eps1*4.0/full_width
    total_area=0.0::T
    comp=0.0::T
    #right=last(points)
    right=pop!(points)
    while !isempty(points)
        left=last(points)
        mid=(left.x+right.x)/2.0::T
        fmid=func(mid)
        if abs(left.f+right.f-fmid*2.0)<=eps
            area=((left.f+right.f+fmid*2.0)*(right.x-left.x)/4.0)::T
            (total_area,comp)=neumaier_sum(area, total_area, comp)
            right=pop!(points)
        else
            push!(points, Point(mid, fmid))
        end
    end
    total_area+comp
end


const TOL=1e-10::Float64
const PRECISE_RESULT=0.527038339761566009286263102166809763899326865179511011538::Float64

println("Validating result precision:")
println("integrate:")
precision=abs(PRECISE_RESULT-integrate(x->sin(x^2), [0.0, 1.0, 2.0, sqrt(8*pi)], TOL));
println("Precision=", precision)
println("Required precision=", TOL)

println("Benchmarking integration with sorting sub-interval areas")
b=@benchmarkable integrate(x->sin(x^2), [0.0, 1.0, 2.0, sqrt(8*pi)], TOL)
tune!(b)
println(run(b))

