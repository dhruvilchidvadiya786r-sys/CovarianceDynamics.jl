###############################################################################
# experiments/solver_comparison.jl
#
# Compare basic SDE solvers available in DifferentialEquations.jl
#
# Solvers used:
#   - EM()     : Euler-Maruyama (basic, fast)
#   - SOSRI()  : Strong order 1.5 for additive/multiplicative noise (higher accuracy)
#
# No extra packages required (StochasticDiffEq not needed)
###############################################################################

using Random
using LinearAlgebra
using Statistics
using DifferentialEquations
using CovarianceDynamics

# -----------------------------
# Reproducibility
# -----------------------------
Random.seed!(123)

# -----------------------------
# Problem setup
# -----------------------------
n = 2
Cbar = Matrix{Float64}(I, n, n)
U    = Matrix{Float64}(I, n, n)

params = CovarianceDynamics.CovMemoryParams(
    n;
    λ   = 1.0,
    C̄   = Cbar,
    β   = 1.0,
    σψ  = 0.2,
    ε   = 0.1,
    U   = U,
    η   = 1.0
)

tspan = (0.0, 10.0)

# -----------------------------
# Reference solution (very fine steps with EM)
# -----------------------------
prob_fine = covmemory_problem(params, tspan)
sol_fine = solve(prob_fine, EM(); dt = 1e-3, saveat = 0.1)

println("=== CovarianceDynamics.jl :: Solver Comparison ===")
println("Reference solution: EM with dt = 0.001 (steps = $(length(sol_fine.t)))")
println()

# -----------------------------
# Helper to compute L2 error vs reference
# -----------------------------
function l2_error(sol, ref_sol)
    common_times = ref_sol.t
    err = 0.0
    count = 0
    for t in common_times
        u_ref = ref_sol(t)
        u = sol(t)
        err += norm(u - u_ref)^2
        count += 1
    end
    return sqrt(err / count)
end

# -----------------------------
# Coarse dt for comparison
# -----------------------------
dt_coarse = 0.01

# EM coarse
prob = covmemory_problem(params, tspan)
sol_em = solve(prob, EM(); dt = dt_coarse, saveat = 0.1)
error_em = l2_error(sol_em, sol_fine)
steps_em = length(sol_em.t)
println("EM          (dt = $dt_coarse): error = $(round(error_em, digits=6)), steps = $steps_em")

# SOSRI (strong order 1.5)
sol_sosri = solve(prob, SOSRI(); dt = dt_coarse, saveat = 0.1)
error_sosri = l2_error(sol_sosri, sol_fine)
steps_sosri = length(sol_sosri.t)
println("SOSRI       (dt = $dt_coarse): error = $(round(error_sosri, digits=6)), steps = $steps_sosri")

println()
println("Conclusion:")
if error_sosri < error_em
    println("  • SOSRI provides improved accuracy at the same dt.")
    println("  • Higher-order solvers are beneficial in this regime.")
else
    println("  • Euler–Maruyama performs comparably or better at this dt.")
    println("  • Higher-order solvers do not automatically improve accuracy.")
    println("  • Solver choice is regime-dependent.")
end
println("Solver comparison completed successfully.")
