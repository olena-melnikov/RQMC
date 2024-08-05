using Statistics
using JLD2
using ProgressMeter


function rmse_dict_2stage(refrence_val, methods)
    result = []
    for set in methods
        push!(result, sqrt(mean((set .- refrence_val).^2)))
    end
    return result 
end

function solve_2stage_repeatedly(dim, M, N, m, beta, method)
    M = (method_is_nonrandom(method)) ? 1 : M 

    Random.seed!(123)
    c = rand(Uniform(0.5,1.),dim)
    U = 5*ones(dim)

    numpy = pyimport("numpy.random")
    seed_papa = numpy.default_rng(0x3034c61a9ae04ff8cb62ab8ec2c4b501)
    seedlings = seed_papa.spawn(M)

     optima = []

    
    @showprogress for i in 1:M
        set = generate_2stage_set(method, dim, N, m, seedlings[i])
        optimum = solve_stage_problem(set, dim, c, U, m, beta)
        push!(optima, optimum)
    end
    
    return optima
end

function run_one_method(method::String, sN::Int64, eN::Int64, m::Int64, M::Int64, dim::Int64, beta::Float64)
    opt_values = []
    for N in sN:eN
        push!(opt_values, solve_2stage_repeatedly(dim, M, 2^N, m, beta, method))
    end
    display(typeof(opt_values))
    return opt_values
end

function compute_methods(methods, sN::Int64, eN::Int64, m::Int64, M::Int64, dim::Int64, beta::Float64)
    res = Dict()
    methods_dict = Dict()
    res["sN"], res["eN"] = sN, eN
    params = Dict("m"=> m, "M"=>M, "n"=> dim, "beta"=> beta, "type"=>"2stage")
    res["params"] = params
    for method in methods
        println("-------------"*method*"----------")
        methods_dict[method] = run_one_method(method, sN, eN, m, M, dim, beta)
    end
    res["methods"] = methods_dict
    save_result("DATA_2stage", res)
    return res
end

function compute_refrence_val2stage(eN::Int64, m::Int64, M::Int64, dim::Int64, beta::Float64)
    res = Dict()
    methods_dict = Dict()
    res["sN"], res["eN"] = eN, eN
    params = Dict("m"=> m, "M"=>M, "n"=> dim, "beta"=> beta, "type"=>"2stage")
    res["params"] = params
    println("-------------Computing reference----------")
    methods_dict["Sobol_S"] = run_one_method("Sobol_S", eN, eN, m, M, dim, beta)
    res["methods"] = methods_dict
    display(mean(methods_dict["Sobol_S"][1]))
    res["ref"] = mean(methods_dict["Sobol_S"][1])
    save_result("REFRENCE_2stage", res)
    return res
end

function run_everything_2stage(methods, sN, eN, m, M, dim, beta, ref_eN)
    #figure out directory; maybe introduce an additional function for that 
    cd(@__DIR__)
    result_path = joinpath(@__DIR__, "../results/")
    folder_name = "2stage" * string(Dates.today()) * string(now())
    new_folder_path = joinpath(result_path, folder_name)
    
    if !isdir(new_folder_path)
        mkdir(new_folder_path)
    else
        println("Folder already exists.")
    end
    
    cd(new_folder_path)
    println("Current directory: ", pwd())

    #actually run the stuff
    compute_methods(methods, sN, eN, m, M, dim, beta)
    compute_refrence_val2stage(ref_eN, m, M, dim, beta)

    #refactor data for plotting
    data_path = find_and_open_file(pwd(), "DATA")
    println(data_path)
    ref_path = find_and_open_file(pwd(), "REFRENCE")

    refactor_data_fromfile(data_path, ref_path)
    refac_path = find_and_open_file(pwd(), "REFAC")
    plot_rmse_and_bias(refac_path)

end