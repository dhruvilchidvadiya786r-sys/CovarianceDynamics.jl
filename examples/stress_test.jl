###############################################################################
# stress_test.jl
#
# Numerical stress testing for CovarianceDynamics.jl
#
# Purpose:
#   - expose numerical failure modes under extreme regimes
#   - quantify SPD violations (not assert against them)
#   - verify long-time stability (no NaN / Inf)
#
# IMPORTANT:
# This test is NOT physically meaningful.
# It is a diagnostic tool for numerical robustness.
###############################################################################

using Random
using LinearAlgebra
using Statistics
using DifferentialEquations
using CovarianceDynamics

# ---------------------------------------------------------------------
# Reproducibility
# ---------------------------------------------------------------------
Random.seed!(999)

# ---------------------------------------------------------------------
# Problem dimension
# ---------------------------------------------------------------------
n = 2

# ---------------------------------------------------------------------
# Reference covariance
# ---------------------------------------------------------------------
C̄ = Matrix{Float64}(I, n, n)

# ---------------------------------------------------------------------
# Noise structure
# ---------------------------------------------------------------------
U = Matrix{Float64}(I, n, n)

# ---------------------------------------------------------------------
# Extreme parameter regime (intentionally adversarial)
# ---------------------------------------------------------------------
params = CovMemoryParams(
    n;
    λ   = 0.2,     # weak mean reversion
    C̄   = C̄,
    β   = 1.0,
    σψ  = 0.5,     # large memory noise
    ε   = 0.3,     # large covariance noise
    U   = U,
    η   = 0.2      # slow memory decay
)

# ---------------------------------------------------------------------
# Long horizon
# ---------------------------------------------------------------------
tspan = (0.0, 100.0)

# ---------------------------------------------------------------------
# Construct SDE problem
# ---------------------------------------------------------------------
prob = covmemory_problem(params, tspan)

# ---------------------------------------------------------------------
# Solve with explicit Euler–Maruyama
# NOTE: EM does NOT preserve manifold constraints
# ---------------------------------------------------------------------
sol = solve(
    prob,
    EM();
    dt = 5e-4
)

# ---------------------------------------------------------------------
# Helper diagnostics
# ---------------------------------------------------------------------
function min_eig(u::AbstractVector, n::Int)
    C = reshape(u[1:n^2], n, n)
    return minimum(eigvals(Symmetric(C)))
end

function frob_norm(u::AbstractVector, n::Int)
    C = reshape(u[1:n^2], n, n)
    return norm(C)
end

# ---------------------------------------------------------------------
# Diagnostics
# ---------------------------------------------------------------------
min_eigs = [min_eig(u, n) for u in sol.u]
norms    = [frob_norm(u, n) for u in sol.u]

spd_fraction = mean(min_eigs .> -1e-8)
worst_eig    = minimum(min_eigs)

finite_ok = all(isfinite, norms)

# ---------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------
println("=== CovarianceDynamics.jl :: Numerical Stress Test ===")
println("Time horizon           : $tspan")
println("Number of steps        : $(length(sol.t))")
println()
println("Extreme parameters:")
println("  λ     = $(params.λ)")
println("  σψ    = $(params.σψ)")
println("  ε     = $(params.ε)")
println("  η     = $(params.memory.η)")
println()
println("Diagnostics:")
println("  Finite values              : $finite_ok")
println("  Fraction SPD states        : $(round(spd_fraction, digits=4))")
println("  Worst min eigenvalue       : $(round(worst_eig, digits=6))")
println("  Mean ||C||_F               : $(mean(norms))")
println("  Std  ||C||_F               : $(std(norms))")
println("  Max  ||C||_F               : $(maximum(norms))")

# ---------------------------------------------------------------------
# Hard failure only for catastrophic breakdown
# ---------------------------------------------------------------------
if !finite_ok
    error("Numerical instability detected: NaN or Inf encountered.")
end
