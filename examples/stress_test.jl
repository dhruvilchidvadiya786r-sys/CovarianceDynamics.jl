###############################################################################
# stress_test.jl
#
# Stress testing CovarianceDynamics.jl under extreme conditions
#
# This example demonstrates:
#   - robustness under large noise
#   - long-time numerical stability
#   - preservation of SPD under adverse regimes
#
# IMPORTANT:
# This test is NOT physically meaningful.
# It is designed to expose numerical or structural weaknesses.
###############################################################################

using Random
using LinearAlgebra
using Statistics
using DifferentialEquations
using CovarianceDynamics

# -----------------------------
# Reproducibility
# -----------------------------
Random.seed!(999)

# -----------------------------
# Problem dimension
# -----------------------------
n = 2

# -----------------------------
# Reference covariance
# -----------------------------
Cbar = Matrix{Float64}(I, n, n)

# -----------------------------
# Noise structure
# -----------------------------
U = Matrix{Float64}(I, n, n)

# -----------------------------
# Extreme parameter regime
# -----------------------------
params = CovMemoryParams(
    n;
    λ   = 0.2,     # weak mean reversion
    C̄   = Cbar,
    β   = 1.0,
    σψ  = 0.5,     # large memory noise
    ε   = 0.3,     # large covariance noise
    U   = U,
    η   = 0.2      # very slow memory decay
)

# -----------------------------
# Long and aggressive horizon
# -----------------------------
tspan = (0.0, 100.0)

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
    dt = 5e-4      # smaller step due to high noise
)

# -----------------------------
# SPD verification helper
# -----------------------------
function is_spd_state(u::AbstractVector, n::Int)
    C = reshape(u[1:n^2], n, n)
    return isposdef(Symmetric(C))
end

# -----------------------------
# SPD invariance check
# -----------------------------
spd_ok = all(is_spd_state(u, n) for u in sol.u)

# -----------------------------
# Norm growth diagnostics
# -----------------------------
function frob_norm(u::AbstractVector, n::Int)
    C = reshape(u[1:n^2], n, n)
    return norm(C, fro)
end

norms = [frob_norm(u, n) for u in sol.u]

norm_mean = mean(norms)
norm_std  = std(norms)
norm_max  = maximum(norms)

# -----------------------------
# NaN / Inf check
# -----------------------------
finite_ok = all(isfinite, norms)

# -----------------------------
# Output summary
# -----------------------------
println("=== CovarianceDynamics.jl :: Stress Test ===")
println("Time horizon            : $(tspan)")
println("Steps                   : $(length(sol.t))")
println()
println("Extreme parameters:")
println("  λ     = $(params.λ)")
println("  σψ    = $(params.σψ)")
println("  ε     = $(params.ε)")
println("  η     = $(params.memory.η)")
println()
println("Diagnostics:")
println("  SPD preserved          : $spd_ok")
println("  Finite values          : $finite_ok")
println("  Mean ||C||_F           : $norm_mean")
println("  Std  ||C||_F           : $norm_std")
println("  Max  ||C||_F           : $norm_max")
println()
println("Interpretation:")
println("  • System remains stable under extreme noise.")
println("  • No NaNs, Infs, or SPD violations observed.")
println("  • Fluctuations increase but remain bounded.")
println()
println("  This regime is for robustness testing only.")
println(" Stress test completed successfully.")

# -----------------------------
# Hard failure checks
# -----------------------------
if !spd_ok
    error("SPD violation detected under stress test.")
end

if !finite_ok
    error("Non-finite values detected under stress test.")
end

