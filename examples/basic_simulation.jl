###############################################################################
# basic_simulation.jl
#
# Minimal sanity check for CovarianceDynamics.jl
#
# This example demonstrates:
#   - correct API usage
#   - short-time stochastic simulation
#   - preservation of symmetric positive definiteness (SPD)
#
# This file intentionally avoids:
#   - long simulations
#   - statistics
#   - plotting
#
# It is designed to run quickly and deterministically.
###############################################################################

using Random
using LinearAlgebra
using DifferentialEquations
using CovarianceDynamics

# -----------------------------
# Reproducibility
# -----------------------------
Random.seed!(42)

# -----------------------------
# Problem dimension
# -----------------------------
n = 2

# -----------------------------
# Reference covariance (target)
# -----------------------------
Cbar = Matrix{Float64}(I, n, n)

# -----------------------------
# Noise structure matrix
# -----------------------------
U = Matrix{Float64}(I, n, n)

# -----------------------------
# Model parameters
# -----------------------------
params = CovMemoryParams(
    n;
    λ   = 1.0,     # mean-reversion strength
    C̄   = Cbar,   # reference covariance
    β   = 1.0,     # operator scaling
    σψ  = 0.2,     # memory noise strength
    ε   = 0.1,     # covariance noise strength
    U   = U,       # noise structure
    η   = 2.0      # memory decay rate
)

# -----------------------------
# Time span (short run)
# -----------------------------
tspan = (0.0, 1.0)

# -----------------------------
# Construct SDE problem
# -----------------------------
prob = covmemory_problem(params, tspan)

# -----------------------------
# Solve using Euler–Maruyama
# -----------------------------
sol = solve(
    prob,
    EM();
    dt = 1e-3
)

# -----------------------------
# SPD verification helper
# -----------------------------
function is_spd_state(u::AbstractVector, n::Int)
    C = reshape(u[1:n^2], n, n)
    return isposdef(Symmetric(C))
end

# -----------------------------
# Check SPD invariance
# -----------------------------
spd_ok = all(is_spd_state(u, n) for u in sol.u)

# -----------------------------
# Output summary
# -----------------------------
println("=== CovarianceDynamics.jl :: Basic Simulation ===")
println("Dimension           : n = $n")
println("Time span            : $tspan")
println("Number of steps      : $(length(sol.t))")
println("SPD preserved        : $spd_ok")
println("Final state vector   :")
println(sol.u[end])

# -----------------------------
# Exit status
# -----------------------------
if !spd_ok
    error("SPD violation detected in basic simulation.")
end

println("✅ Basic simulation completed successfully.")

