PORTFOLIO_OPTIMIZATION="run_portfolio_problem.jl"
UTILITY_PROBLEM="run_utility_problem.jl"

echo $PORTFOLIO_OPTIMIZATION
time julia --project=../. $PORTFOLIO_OPTIMIZATION
echo $UTILITY_PROBLEM
time julia --project=../. $UTILITY_PROBLEM
