using JLD2
using Statistics
using ProgressMeter
using Dates
using RQMC

#sN, eN, m, M, dim, beta, ref_eN 
methods = ["LatinHypercube_S", "Sobol_S", "Halton_S", "MC"]


stage_09 = (methods, 8, 12, 50, 50, 50, 0.9, 15)
stage_095 = (methods, 8, 12, 50, 50, 50, 0.95, 15)

instances = [stage_09, stage_095]

for i in instances
    run_everything_2stage(i[1], i[2], i[3], i[4], i[5], i[6], i[7], i[8])
end

