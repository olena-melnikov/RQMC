
using JLD2, FileIO
using Dates
using UnPack
using PyCall
using ProgressMeter
using Statistics


function solve_repeatedly(method, M, N, mu, Q, beta, R, type)
    M = (method_is_nonrandom(method)) ? 1 : M 

    numpy = pyimport("numpy.random")
    seed_papa = numpy.default_rng(0x3034c61a9ae04ff8cb62ab8ec2c4b501)
    seedlings = seed_papa.spawn(M)

    optima = []
    
    dim = length(mu)
    if type=="uniform"
        @showprogress for i in 1:M
            uniform_set = uniform_samples(method, dim, 2^N, seedlings[i])
            set = uniform_transform(mu, Q, uniform_set)
            optimum = solve_mc_problem(set, mu, beta, R) 
            push!(optima, optimum)
        end
    elseif type=="normal"
        @showprogress for i in 1:M
            if method == "Sobol_PCA_S"
                Q = sigma_pca(Q * Q')
            end
            uniform_set = uniform_samples(method, dim, 2^N, seedlings[i])
            set = normal_transform(mu, Q, uniform_set)
            optimum = solve_mc_problem(set, mu, beta, R)
            push!(optima, optimum)
        end
    end

    return optima
end



#The type string is either normal or uniform 
function compute_convergence(method, sN, eN, beta, R, M, mu, Q, type)
    optima_array = []
    for N in sN:eN
        optima = solve_repeatedly(method, M, N, mu, Q, beta, R, type)
        push!(optima_array, optima)
    end
    return optima_array
end



function run_simulation(dim::Int64, sN::Int64, eN::Int64, methods::Vector{String}, beta::Float64, M::Int64, R::Float64, type, q=1.)
    params = Dict("dim"=>dim, "beta"=>beta, "M"=>M, "R"=>R,"type"=>type)
    simulation = Dict()
    experiment = "DATA_CV@R_$(type)$(dim)$(beta)$(R)"
    mu, Sigma, Q = gen_norm(dim) 

    for method in methods
        println(method)
        obj = compute_convergence(method, sN, eN, beta, R, M, mu, Q, type)
        println("Done with $method")
        simulation[method] = obj
    end
    result = Dict("params"=>params, "sN"=> sN, "eN"=> eN, "methods"=>simulation)

    save_result(experiment, result)
end

function compute_refrence_val_cvar(dim::Int64, eN::Int64, beta::Float64, M::Int64, R::Float64, type, q=1.)
    experiment = "REFRENCE_CV@R_$(type)$(dim)$(beta)$(R)"
    params = Dict("dim"=>dim, "beta"=>beta, "M"=>M, "R"=>R,"type"=>type)
    mu, Sigma, Q = gen_norm(dim)
    if type == "uniform"
        println("\u001b[36mSolving uniform refrence problem.")
        numpy = pyimport("numpy.random")
        seed_papa = numpy.default_rng(0x3034c61a9ae04ff8cb62ab8ec2c4b501)
        seedlings = seed_papa.spawn(M)
        optima = []
        @showprogress for i in 1:M
            samples = uniform_samples("Sobol_S", dim, 2^(eN+1), seedlings[i])
            samples = uniform_transform(mu, Q, samples)
            opt = solve_mc_problem(samples, mu, beta, R)
            push!(optima, opt)
        end
        ref = mean(optima)
    elseif type == "normal"
        println("\u001b[36mSolving normal refrence problem.")
        ref = solve_op_problem(mu, Sigma, beta, R)
    end
    result = Dict()
    result["ref"] = ref
    result["params"] = params
    result["eN"] = eN
    save_result(experiment, result)
    println("\u001b[36mDone solving refrence problem.")
end


function run_everything(dim::Int, sN:: Int64, eN::Int64, ref_eN::Int64, methods::Vector{String}, beta::Float64, M::Int64, R::Float64, type::String, q=0.1)
    #create folder to save results
    cd(@__DIR__)
    result_path = joinpath(@__DIR__, "../results/")
    folder_name = type * string(Dates.today()) * string(now())
    new_folder_path = joinpath(result_path, folder_name)
    
    if !isdir(new_folder_path)
        mkdir(new_folder_path)
    else
        println("Folder already exists.")
    end
    
    cd(new_folder_path)
    println("Current directory: ", pwd())

    #run simulation
    run_simulation(dim, sN, eN, methods, beta, M , R, type, q)
    #compute expected value
    compute_refrence_val_cvar(dim, ref_eN, beta, M , R, type, q)

    #refactor data for plotting
    data_path = find_and_open_file(pwd(), "DATA")
    println(data_path)
    ref_path = find_and_open_file(pwd(), "REFRENCE")

    refactor_data_fromfile(data_path, ref_path)
    refac_path = find_and_open_file(pwd(), "REFAC")
    plot_rmse_and_bias(refac_path)

end