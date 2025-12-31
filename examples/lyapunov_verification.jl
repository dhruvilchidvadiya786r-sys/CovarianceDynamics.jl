###############################################################################
# lyapunov_verification.jl
#
# Empirical stability verification for CovarianceDynamics.jl
#
# This example demonstrates:
#   - long-time boundedness
#   - absence of explosion
#   - numerical stability under stochastic forcing
#
# IMPORTANT:
# This is an EMPIRICAL Lyapunov diagnostic.
# No theoretical Lyapunov theorem is claimed or implied.
###############################################################################

using Random
using LinearAlgebra
using Statistics
using DifferentialEquations
using CovarianceDynamics

# -----------------------------
# Reproducibility
# -----------------------------
Random.seed!(2024)

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
# Model parameters
# -----------------------------
params = CovMemoryParams(
    n;
    λ   = 1.0,
    C̄   = Cbar,
    β   = 1.0,
    σψ  = 0.2,
    ε   = 0.1,
    U   = U,
    η   = 2.0
)

# -----------------------------
# Long time horizon
# -----------------------------
tspan = (0.0, 50.0)

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
# Lyapunov-like functional
# -----------------------------
# We use:
#   V(C) = ||C - C̄||_F^2
#
# This is NOT guaranteed to be a true Lyapunov function.
# It is used only as a stability diagnostic.
#
function lyapunov(u::AbstractVector, n::Int, Cbar::AbstractMatrix)
    C = reshape(u[1:n^2], n, n)
    return norm(C - Cbar)^2  # Frobenius norm (default for matrices)
end
# -----------------------------
# Evaluate along trajectory
# -----------------------------
V_vals = [lyapunov(u, n, Cbar) for u in sol.u]

# -----------------------------
# Stability diagnostics
# -----------------------------
V_mean = mean(V_vals)
V_std  = std(V_vals)
V_max  = maximum(V_vals)
V_min  = minimum(V_vals)

# -----------------------------
# Growth-rate check
# -----------------------------
# Compare early-time and late-time averages
split_idx = Int(length(V_vals) ÷ 2)
V_early = mean(V_vals[1:split_idx])
V_late  = mean(V_vals[split_idx+1:end])

# -----------------------------
# Output summary
# -----------------------------
println("=== CovarianceDynamics.jl :: Lyapunov Verification ===")
println("Time horizon          : $(tspan)")
println("Steps                 : $(length(sol.t))")
println()
println("Lyapunov functional statistics:")
println("  Mean                : $V_mean")
println("  Std                 : $V_std")
println("  Min                 : $V_min")
println("  Max                 : $V_max")
println()
println("Time-split comparison:")
println("  Early-time mean     : $V_early")
println("  Late-time mean      : $V_late")
println()

