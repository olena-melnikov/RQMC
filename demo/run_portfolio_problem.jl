using RQMC
# The arguments for run_everything are
# dim::Int, sN:: Int64, eN::Int64, methods::Vector{String}, beta::Float64, M::Int64, R::Float64, type::String)
# type can be either 'normal' or 'uniform'

methods_normal = ["Sobol_S", "MC", "LatinHypercube_S", "Halton_S", "Sobol_PCA_S"]
methods_uniform = ["Sobol_S", "MC", "LatinHypercube_S", "Halton_S"]

normal_09 = (250, 8, 12, 0, methods_normal, 0.9, 100, 1., "normal")
normal_095 = (250, 8, 12, 0, methods_normal, 0.95, 100, 1., "normal")

uniform_09 = (250, 8, 12, 14, methods_uniform, 0.9, 100, 1., "uniform")
uniform_095 = (250, 8, 12, 14, methods_uniform, 0.95, 100, 1., "uniform")

instances = [normal_09, normal_095]

for i in instances
    run_everything(i[1], i[2], i[3], i[4], i[5], i[6],i[7], i[8], i[9])
end


