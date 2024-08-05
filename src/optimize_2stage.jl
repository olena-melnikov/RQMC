using JuMP
using HiGHS
using LinearAlgebra

function q(x, t)
    println("This is t1, t2, t2")
    z = max.(zeros(length(t[2])), t[2] - (t[1] * x))
    res = [z[i]*t[3][i] for i in range(1, length(t[3]))]
    return sum(res)
end


function solve_stage_problem(samples, dim::Int64, c::Vector{Float64}, U::Vector{Float64}, m::Int64,beta::Float64)
    N = length(samples)

    model = Model(HiGHS.Optimizer)
    set_string_names_on_creation(model, false)
    set_silent(model)
 
    @variable(model, z[1:N]>=0)
    @variable(model, t)
    @variable(model, x[1:dim]>=0)
    @variable(model, h[1:(N*m)]>=0)

    @objective(model, Min, dot(c,x) + t + 1/(N*(1-beta))*sum(z[j] for j in 1:N))

    @constraint(model, x <= U)
    for j in 0:(N-1)
        @constraint(model, h[(j*m+1):(j+1)*m] + samples[j+1][1]*x >= samples[j+1][2])
        @constraint(model, samples[j+1][3]' * h[(j*m+1):(j+1)*m] -t <= z[j+1])
    end
    optimize!(model)
    return objective_value(model)
end

