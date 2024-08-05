using JuMP
using SCS
using HiGHS
using LinearAlgebra

function  solve_op_problem(mu, Sigma, beta, R)

    dim = length(mu)
    Sigma_root = sqrt(Sigma)
    z_beta = quantile.(Normal(), beta)
    rho = exp(-(0.5)*z_beta^2)/((1-beta)*sqrt(2pi))
    Q = rho*Sigma_root

    model = Model(optimizer_with_attributes(SCS.Optimizer, "eps_rel" => 1e-8, "eps_abs" =>1e-8))
    set_string_names_on_creation(model, false)
    set_silent(model)

    @variable(model, t)
    @variable(model, x[1:dim]>=0.)

    @constraint(model, [t+ mu'x; Q*x] in SecondOrderCone())
    @constraint(model, sum(x[i] for i in 1:dim)==1.)
    @constraint(model, mu' * x >= R)



    @objective(model, Min, t)

    optimize!(model)
    obj_val = objective_value(model)
    println([value(x[i]) for i in 1:dim])
    println(sum([value(x[i]) for i in 1:dim]))
    println(value(t))
    return obj_val
end


function solve_mc_problem(samples, mu, beta, R)

    dim = length(mu)
    N = size(samples,2)

    model = Model(HiGHS.Optimizer)
    set_string_names_on_creation(model, false)
    set_silent(model)

    @variable(model, z[1:N]>=0)
    @variable(model, t)
    @variable(model, x[1:dim]>=0)

    
   
    @constraint(model, c[j = 1:N], (-samples[:,j])' * x - t <= z[j]) 
    @constraint(model, sum(x[i] for i in 1:dim)==1.)
    @constraint(model, mu' * x>=R)

    @objective(model, Min, t+ 1/(N*(1-beta))*sum(z[j] for j in 1:N))

 

    optimize!(model)
    return objective_value(model)
end

