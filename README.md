[![DOI](https://zenodo.org/badge/838065528.svg)](https://zenodo.org/doi/10.5281/zenodo.13227276)

# Supplementary code for the manuscript: Randomized quasi-Monte Carlo methods for risk-averse stochastic optimization
This repository contains supplementary code for the manuscript
> Olena Melnikov and Johannes Milz, 2024,
> Randomized quasi-Monte Carlo methods for risk-averse stochastic optimization,
> https://doi.org/10.48550/arXiv.2408.02842

## Abstract
We establish epigraphical and uniform laws of large numbers for sample-based approximations of law invariant risk functionals. Our sample-based approximation schemes include Monte Carlo (MC) and certain randomized quasi-Monte Carlo integration (RQMC) methods, such as scrambled net integration. Our results can be applied to the approximation of risk-averse stochastic programs and (simple) risk-averse stochastic variational inequalities. Our numerical simulations empirically demonstrate that RQMC approaches based on scrambled Sobol' sequences can yield smaller bias and root mean square error than MC methods for risk-averse optimization.

## Getting started

### Julia installation and operating system

The simulations were run using Julia version 1.9.3 and macOS 13.4 (Mac14,7, Apple M2).

### Downloading the package

To download the package, execute
```
git clone git@github.com:olena-melnikov/RQMC.git
```

### Working with RQMC environment

cd to RQMC via
```
cd RQMC
```

Following [4. Working with Environment](https://pkgdocs.julialang.org/v1/environments/), 
execute the following command in your [Pkg REPL](https://docs.julialang.org/en/v1/stdlib/Pkg/):
```julia
activate .
```

and subsequently
```julia
instantiate
```

### Running simulations and generating plots
To reproduce the simulations in the paper, run the
shell script:

```
cd demo
./run_simulation.sh
```
This process will generate a separate folder for each experiment within the results directory. Each folder will be named after the experiment and the time it was conducted. Inside the folder, you will find all relevant simulation data in both .jld2 and .txt formats, as well as the corresponding plots.

## Authors
The module has been implemented by Olena Melnikov.
