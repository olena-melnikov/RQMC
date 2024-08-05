using Random
using Distributions
using QuasiMonteCarlo
using Sobol
using LinearAlgebra
using PyCall


function gen_norm(dim::Int64)
    Random.seed!(123)
    d_mu = Uniform(0.9, 1.2)
    d_Q = Uniform(0.0, 0.1)

    mu = rand(d_mu, dim)
    Q = rand(d_Q, (dim, dim))
    Sigma = Q * Q'
    sQ = sqrt(Sigma)
    return mu, Sigma, sQ
end

function sigma_pca(Sigma::Matrix{Float64})
    eig_decomp = eigen(Sigma)
    eigenvalues = eig_decomp.values
    eigenvectors = eig_decomp.vectors

    # Sort eigenvalues from largest to smallest
    idx = sortperm(eigenvalues, rev=true)
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]

    # Compute the matrix B
    B = Diagonal(sqrt.(eigenvalues)) * eigenvectors'

    return B'
end

function uniform_samples(method::String, point_dim:: Int64, N::Int64, seed)
    scrambled = endswith(method, "_S") ? true : false
    scipy_qmc = pyimport("scipy.stats.qmc")
    numpy_random = pyimport("numpy.random")

    if startswith(method, "Halton")
        sampler = scipy_qmc.Halton(d=point_dim, scramble = scrambled, seed=seed)
        return sampler.random(N)'
    elseif startswith(method, "LatinHypercube")
        sampler = scipy_qmc.LatinHypercube(d=point_dim, scramble = scrambled, seed=seed)
        return sampler.random(N)'
    elseif startswith(method, "Sobol")
        sampler = scipy_qmc.Sobol(d=point_dim, scramble = scrambled, seed=seed)
        return sampler.random_base2(Int(log2(N)))'
    elseif method =="MC"
        mc_samples =  seed.uniform(0.,1., (point_dim, N))
        return mc_samples
    end
    
end

function normal_transform(mu, Q, uniform_samples)
    norm_samples = quantile.(Normal(), uniform_samples)
    norm_samples = mu .+ Q * norm_samples
    return norm_samples
end


function uniform_transform(mu, Q, uniform_samples)
    uniform_samples = mu .+ sqrt(12) * Q * uniform_samples
    return uniform_samples
end

