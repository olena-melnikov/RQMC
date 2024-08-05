using Test 
using Distributions
using Random 
using PyCall
using RQMC
using ProgressMeter
#N here always denotes the sample size


# generate throuple (T,d,e)
function transform_vector_to_throuple(point::Vector{Float64}, dim, m)
    d, e = 50.0*point[1:m].+50., 2.0*point[m+1:2m].+ 2.
    T = 0.5*reshape(point[2m+1:end], (m,dim)).+ 0.5
    return (T,d,e)
end


# generate sample set according to 'method': [(T1,d1,e1); (T2, d2, e2), ..., (TN, dN, eN)]
function generate_2stage_set(method::String,dim::Int64, N::Int64, m::Int64, seed)
    @assert ispow2(N) "Sample size is not a power of 2 >:("
    point_dim = 2m + m*dim
    points = uniform_samples(method, point_dim,N, seed)
    samples =  [transform_vector_to_throuple(points[:,i], dim, m) for i in range(1,N)]
    return samples
end


function method_is_nonrandom(method::String)
    return (method in ["Halton", "Sobol", "LatinHypercube"])
end
