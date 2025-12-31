###############################################################################
# ergodicity_demo.jl
#
# Empirical verification of mixing / ergodicity for CovarianceDynamics.jl
#
# This example demonstrates:
#   - long-time stochastic simulation
#   - stationarity (bounded fluctuations)
#   - decay of temporal autocorrelation
#
# IMPORTANT:
# This is NOT a proof of ergodicity.
# It is an empirical diagnostic consistent with hypoelliptic dynamics.
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
    η   = 2.0        # moderate memory decay
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
# Solve (Euler–Maruyama)
# -----------------------------
sol = solve(
    prob,
    EM();
    dt = 1e-3
)

# -----------------------------
# Extract time series
# -----------------------------
# We monitor diagonal covariance entries
vals_11 = [u[1] for u in sol.u]   # C[1,1]
vals_22 = [u[4] for u in sol.u]   # C[2,2]

# -----------------------------
# Basic stationarity diagnostics
# -----------------------------
μ11, σ11 = mean(vals_11), std(vals_11)
μ22, σ22 = mean(vals_22), std(vals_22)

# -----------------------------
# Autocorrelation function
# -----------------------------
function autocorr(x::AbstractVector, lag::Int)
    μ = mean(x)
    num = sum((x[1:end-lag] .- μ) .* (x[1+lag:end] .- μ))
    den = sum((x .- μ).^2)
    return num / den
end

# -----------------------------
# Evaluate autocorrelation decay
# -----------------------------
lags = [10, 50, 100, 200, 500, 1000, 2000]
ac_vals = [(lag, autocorr(vals_11, lag)) for lag in lags]

# -----------------------------
# Output summary
# -----------------------------
println("=== CovarianceDynamics.jl :: Ergodicity Demo ===")
println("Time horizon          : $(tspan)")
println("Steps                 : $(length(sol.t))")
println()
println("Stationarity check (C[1,1]):")
println("  Mean                : $μ11")
println("  Std                 : $σ11")
println()
println("Stationarity check (C[2,2]):")
println("  Mean                : $μ22")
println("  Std                 : $σ22")
println()
println("Autocorrelation decay for C[1,1]:")
for (lag, ac) in ac_vals
    println("  lag = $(lpad(lag,4)) → autocorr = $(round(ac, digits=4))")
end

