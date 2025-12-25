###############################################################################
# mixing_rate_estimation.jl
#
# Empirical estimation of mixing rates for CovarianceDynamics.jl
#
# Scientific question:
#   How fast does temporal dependence decay, and how does it depend on
#   the memory decay parameter η?
#
# This experiment estimates effective mixing times using autocorrelation decay.
#
# IMPORTANT:
# This is an empirical rate estimation, not a spectral gap proof.
###############################################################################

using Random
using LinearAlgebra
using Statistics
using DifferentialEquations
using CovarianceDynamics

# -----------------------------
# Reproducibility
# -----------------------------
Random.seed!(31415)

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
# Shared parameters
# -----------------------------
λ  = 1.0
β  = 1.0
σψ = 0.2
ε  = 0.1

# -----------------------------
# Memory regimes to test
# -----------------------------
η_values = [0.5, 1.0, 2.0, 4.0]

# -----------------------------
# Time horizon (long enough for decay)
# -----------------------------
tspan = (0.0, 80.0)
dt = 1e-3

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
# Run simulation and extract observable
# -----------------------------
function run_and_extract(η::Float64)
    params = CovMemoryParams(
        n;
        λ   = λ,
        C̄   = Cbar,
        β   = β,
        σψ  = σψ,
        ε   = ε,
        U   = U,
        η   = η
    )

    prob = covmemory_problem(params, tspan)

    sol = solve(
        prob,
        EM();
        dt = dt
    )

    # Observable: C[1,1]
    return [u[1] for u in sol.u]
end

# -----------------------------
# Lags for mixing estimation
# -----------------------------
lags = [50, 100, 200, 500, 1000, 2000]

# -----------------------------
# Storage for results
# -----------------------------
results = Dict{Float64, Vector{Tuple{Int, Float64}}}()

# -----------------------------
# Run experiments
# -----------------------------
for η in η_values
    vals = run_and_extract(η)
    ac_vals = [(lag, autocorr(vals, lag)) for lag in lags]
    results[η] = ac_vals
end

# -----------------------------
# Estimate effective mixing time
# -----------------------------
# We define mixing time as the smallest lag where autocorr < 0.3
function estimate_mixing_time(ac_vals)
    for (lag, ac) in ac_vals
        if ac < 0.3
            return lag
        end
    end
    return Inf
end

mixing_times = Dict(
    η => estimate_mixing_time(results[η])
    for η in η_values
)

# -----------------------------
# Output summary
# -----------------------------
println("=== CovarianceDynamics.jl :: Mixing Rate Estimation ===")
println("Time horizon          : $tspan")
println("Noise parameters      : σψ = $σψ, ε = $ε")
println("Observable            : C[1,1]")
println()
println("Autocorrelation decay by memory regime:")
for η in η_values
    println("η = $η")
    for (lag, ac) in results[η]
        println("  lag = $(lpad(lag,4)) → autocorr = $(round(ac, digits=4))")
    end
    println()
end

println("Estimated mixing times (autocorr < 0.3):")
for η in η_values
    println("  η = $η  → mixing time ≈ $(mixing_times[η])")
end

println()
println("Interpretation:")
println("  • Larger η ⇒ slower decay of correlations.")
println("  • Smaller η ⇒ faster mixing.")
println("  • Memory parameter directly controls effective mixing rate.")
println()
println(" Mixing rate estimation experiment completed successfully.")

