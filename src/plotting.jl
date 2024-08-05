using JLD2, FileIO
using Plots, LaTeXStrings
using ColorSchemes
using Statistics
using Dates






function base_plot_from_dict(methods, params, sN, eN, lw::Float64=3.)

    # Options that relate to the style of the plots 
    plot_font = "Computer Modern"
    default(fontfamily=plot_font)

    palette = ColorSchemes.tab10

    linestyles = [:solid, :dash, :dot, :dashdot, :dashdotdot]
    
    
    markerstyles =  [
        :circle, :rect, :utriangle,
        :diamond, :hexagon, :cross
    ]
    ms = [6, 5, 7, 7, 7, 7, 7]
   
    method_descriptions =
    Dict("Sobol_S" => "scrambled Sobol'", "Halton_S" => "scrambled Halton",
    "LatinHypercube_S" => "scrambled Latin Hypercube", "MC"=> "Monte Carlo",
    "Sobol_PCA_S" => "scrambled Sobol' w/ PCA")


    # Calibration of y-axis and x-axis
    x = [2^i for i in sN:eN]
    ymin = minimum(reduce(vcat, values(methods)))
    ymax = maximum(reduce(vcat, values(methods)))

    if ymin > 0
        plot(xscale=:log2, yscale=:log2)
        y = powers_of_two_in_range(ymin, ymax)
        plot!(yaxis = y)
        plot!(yaxis=(formatter=y->(powerstring2(y))))
    else
        plot(xscale=:log2)
    end
    plot!(xticks=(x, [latexstring("2^{$(j)}") for j in sN:eN]), tickfontsize=14)


    #plot graphs for each method
    i = 1
    for (method, values) in methods
        if method == "Sobol_PCA_S"
            plot!( 
                    x, values,
                    size=(500,500),
                    label=method_descriptions[method],
                    lc= ColorSchemes.berlin10[3],
                    shape=:diamond,
                    markercolor = ColorSchemes.berlin10[3],
                    ls = linestyles[end],
                    ms = ms[end],
                    linewidth = lw,
                    
                )
        else
            plot!( 
                    x, values,
                    size=(500,500),
                    label=method_descriptions[method],
                    lc=palette[i],
                    shape=markerstyles[i],
                    markercolor = palette[i],
                    ls = linestyles[i],
                    ms = ms[i],
                    linewidth = lw,
                    
                )
                i = i+1
        end
    end

    # Generate annotation
    annotation = generate_annotation(params)
    x_ann, y_ann = annotation_position(ymin, ymax, sN, eN)
    annotate!(x_ann, y_ann, annotation, annotationfontsize = 11)

end

function plot_rmse_from_dict(methods, params, sN, eN, lw::Float64=3.)
    base_plot_from_dict(methods, params, sN, eN, lw)

    if params["type"] != "2stage"
        plot_comparison_lines(methods, sN, eN)
    end
    plot!(ylabel = "RMSE", xlabel = "sample size " * L"N")
    savefig(pwd() * "/rmse"*string(now())*".svg")
    savefig(pwd() * "/rmse"*string(now())*".png")
    savefig(pwd() * "/rmse"*string(now())*".pdf")
end


function plot_bias_from_dict(methods, params, sN, eN, lw::Float64=3.)
    base_plot_from_dict(methods, params, sN, eN, lw)
    plot!(ylabel = "bias", xlabel = "sample size " * L"N")
    savefig(pwd() * "/bias"*string(now())*".svg")
    savefig(pwd() * "/bias"*string(now())*".png")
    savefig(pwd() * "/bias"*string(now())*".pdf")
end


function plot_comparison_lines(methods, sN, eN, lw::Float64=3.)
    palette = ColorSchemes.tab10
    x = [2^i for i in sN:eN] 
    if "MC" in keys(methods)
        #plot mc-line
        i = length(methods) + 1
        a,c = least_squares_rounded(x, methods["MC"])
        c = round(c, digits=2)
        c_pow = round(10^c, digits = 2)
        plot!(x, x.^(a)*10^c, lc = palette[i], linewidth = lw, label=L"{%$c_pow}\cdot N^{%$a}")
        delete!(methods, "MC")
        m = +Inf
        e = +Inf
        for (key, value) in methods
            d, f = least_squares_rounded(x, value)
            if m!= min(m, d)
                m = min(m, d)
                e =f
            end
        end
        m = round(m, digits = 2)
       plot!(x, x.^(m)*10^e, lc = palette[i+1], linewidth = lw, ms = 7, mc = palette[i+1], shape =:cross, label=L"{%$c_pow}\cdot N^{%$m}")
        
    end
end


function annotation_position(ymin, ymax, sN, eN)
    log_ymin = floor(log2(abs(ymin)))
    log_ymax = ceil(log2(abs(ymax)))

    y = 2^(log_ymin + (1/4)*(log_ymax-log_ymin))
    x = 2^(sN + (1/4)*(eN-sN))

    return x,y
end

function plot_rmse_and_bias(filepath::String, ndrop=0, ndrop2=0)
    #read file 
    data = load(filepath)
    data = data["res"]
    rmse = data["rmse"]
    bias = data["bias"]

    params = data["params"]
    sN = data["sN"]
    eN = data["eN"]

    if ndrop != 0 || ndrop2 != 0
        sN = sN+ndrop
        eN = eN-ndrop2
        for key in keys(rmse)
            rmse[key] = rmse[key][1+ndrop: end-ndrop2]
            bias[key] = bias[key][1+ndrop: end-ndrop2]
        end
    end

    plot_rmse_from_dict(rmse, params, sN, eN)
    plot_bias_from_dict(bias, params, sN, eN)
end

#------------


function powerstring2(y)
    sgn = sign(y)
    z = Int64((log2(abs(y))))
    if isapprox(y, 0)
        return L"0"
    elseif sgn >= 0 
        return L"2^{%$z}"
    else
        return L"-2^{%$z}"
    end
end

function generate_annotation(params)
    annotation = ""
    display(params)
    for (key,value) in params
        key = latex_representation(key)
        annotation *= (key * " = $value \n")
    end
    return annotation
end


function latex_representation(key)
    latex = Dict(
        "beta"=>L"\beta",
        "dim"=> L"d",
        "M" => L"M",
        "R" => L"R",
        "ref_eN" => "ref",
        "n" => L"d",
        "m" => L"m"
        )
    if key in keys(latex)
        return latex[key]
    end
    return key
end





function save_figure(file_path::String, fontsize)
    file_name = chop(basename(file_path), tail =5)
    folder_path = "/" * dirname(file_path) * "plots$fontsize"
    if !isdir(folder_path)
        mkdir(folder_path)
    end
    savefig(folder_path * "/" * string(file_name) * "_$fontsize.png")
    savefig(folder_path * "/" * string(file_name) * "_$fontsize*.svg")
    savefig( folder_path * "/" * string(file_name) * "_$fontsize*.pdf")
end

function least_squares_rounded(x, y)
    A = [log10.(x) ones(length(x))]
    return round.((A \ log10.(y))[1:2], digits=2)
end

function powers_of_two_in_range(a, b)
    
    log_a = floor(log2(a))
    log_b = ceil(log2(b))
    if length(log_a:log_b) <= 6
        log_a = log_a - 2
        return [2^k for k in log_a:log_b]
    elseif length(log_a:log_b) >= 10
        return [2^k for k in log_a:2:log_b]
    else
        return [2^k for k in log_a:log_b]
    end
end

function symlog2(x)
    return sign(x) * log2(1 + abs(x))
end
