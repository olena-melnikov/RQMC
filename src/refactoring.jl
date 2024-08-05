using FileIO, JLD2
using Statistics

function refactor_data(plt_dict, ref_dict, bias_method)
    ref = ref_dict["ref"]
    methods = plt_dict["methods"]
    data_dict = Dict()
    print(keys(methods))

    data_dict["params"] = plt_dict["params"]
    data_dict["sN"], data_dict["eN"] = plt_dict["sN"], plt_dict["eN"]
    #save info on ref value if appropriate
    if ref_dict["params"]["type"] != "normal"
        data_dict["params"]["ref_eN"] = ref_dict["eN"]
    end
    #compute rmse
    data_dict["rmse"] = Dict()
    for method in keys(methods)
        data_dict["rmse"][method] = []
        for sample_set in methods[method]
            M = length(sample_set)
            rmse =  sqrt((1/M)*sum((ref-sample_set[i])^2 for i in 1:M))
            push!(data_dict["rmse"][method], rmse)
        end 
    end

    #compute bias
    data_dict["bias"] = Dict()
    
        for method in keys(methods)
            println("___"*method*"____")
            data_dict["bias"][method] = []
            for sample_set in methods[method]
                println("------------")
                display(sample_set)
                println(ref)
                println(mean(sample_set))
                println(ref-mean(sample_set))
                push!(data_dict["bias"][method], ref - mean(sample_set))
            end 
            data_dict["bias"][method] = [(ref-mean(sample_set)) for sample_set in methods[method]]
        end
    

    #compute puenktchen 
    sobol_array = plt_dict["methods"][bias_method]
    sobol_tmp = [-x .+ ref for x in sobol_array]
    data_dict["sobol_var"] = [getindex.(sobol_tmp, i) for i in 1:length(sobol_tmp[1])]
    data_dict["bias_method"] = bias_method
    

    display(data_dict)
    return data_dict
end

function refactor_data_fromfile(data_path::String, ref_path::String, bias_method="Sobol_S")
    # read data
    data_plt = load(data_path)
    data_ref = load(ref_path)

    plt_dict = data_plt["res"]
    ref_dict = data_ref["res"]

    # check that ref values make sense 
    if plt_dict["params"] != ref_dict["params"]
        @warn("Refrence Value might be inappropriate.")
    end
    # compute data
    res = refactor_data(plt_dict, ref_dict, bias_method)
  
    # write data to file 
    ref_dict["params"]["eN"] = ref_dict["eN"]
    if haskey(plt_dict["params"],"type")
        experiment = "REFAC_" * plt_dict["params"]["type"] 
    else
        experiment = "REFAC_" * "2stage" 
    end
    save_result_refac(experiment, res, ref_dict["params"])
end
