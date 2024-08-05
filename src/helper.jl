
using JLD2, FileIO
using Dates
function save_result(experiment::String, result, params::Any...)
    experiment_name = experiment * string(Dates.today()) * string(now())
    [experiment_name*=string(param) for param in params ] 
    folder_path = pwd() * "/" * experiment_name
    #cd(@__DIR__)
    mkdir(folder_path)
    txt_file_path = "$folder_path/$experiment_name.txt"
    open(txt_file_path, "w") do file
        write(file, string(result))
    end
    save("$folder_path/$experiment_name.jld2", "res", result)
end




function find_and_open_file(folder_path::String, prefix)
    function search_folder(path::String)
        for entry in readdir(path, join=true)
            if isdir(entry)
                result = search_folder(entry)
                if result != nothing
                    return result
                end
            elseif isfile(entry) && startswith(basename(entry), prefix) && endswith(basename(entry), ".jld2")
                return entry
            end
        end
        return nothing
    end

    result = search_folder(folder_path)
    if result == nothing
        println("No file found that matches the criteria.")
    else
        println("File found: ", result)
    end
    return result
end

function save_result_refac(experiment::String, result, ref_dict, params::Any...)
    folder_name = experiment * string(Dates.today()) * string(now())
    experiment_name = experiment
    [experiment_name*=string(param) for param in params ] 
    folder_path = pwd() * "/$folder_name"
    mkdir(folder_path)
    txt_file_path = "$folder_path/$experiment_name.txt"
    open(txt_file_path, "w") do file
        write(file, "Reference value was computed for \n"
        * string(ref_dict) * "\n" * string(result))
    end
    save("$folder_path/$experiment_name.jld2", "res", result)
    return "$folder_path/$experiment_name.jld2"
end
