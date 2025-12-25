###############################################################################
# memory_effects.jl
#
# Empirical demonstration of memory effects in CovarianceDynamics.jl
#
# This example demonstrates:
#   - how the memory decay parameter η controls persistence
#   - slower vs faster mixing under identical noise conditions
#   - non-Markovian effective behavior of the covariance
#
# IMPORTANT:
# This example compares two simulations differing ONLY in η.
###############################################################################

using Random
using LinearAlgebra
using Statistics
using DifferentialEquations
using CovarianceDynamics

# -----------------------------
# Reproducibility
# -----------------------------
Random.seed!(777)

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
# Shared model parameters
# -----------------------------
λ  = 1.0
β  = 1.0
σψ = 0.2
ε  = 0.1

# -----------------------------
# Two memory regimes
# -----------------------------
η_slow = 2.0    # slow memory decay (strong persistence)
η_fast = 0.5    # fast memory decay (weaker persistence)

# -----------------------------
# Time horizon
# -----------------------------
tspan = (0.0, 50.0)

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
# Simulation helper
# -----------------------------
function run_simulation(η::Float64)
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
        dt = 1e-3
    )

    # Track C[1,1]
    vals = [u[1] for u in sol.u]
    return vals
end

# -----------------------------
# Run both regimes
# -----------------------------
vals_slow = run_simulation(η_slow)
vals_fast = run_simulation(η_fast)

# -----------------------------
# Autocorrelation diagnostics
# -----------------------------
lags = [10, 50, 100, 200, 500, 1000]

ac_slow = [(lag, autocorr(vals_slow, lag)) for lag in lags]
ac_fast = [(lag, autocorr(vals_fast, lag)) for lag in lags]

# -----------------------------
# Output summary
# -----------------------------
println("=== CovarianceDynamics.jl :: Memory Effects Demo ===")
println("Time horizon        : $tspan")
println("Noise parameters    : σψ = $σψ, ε = $ε")
println()
println("Memory regimes:")
println("  Slow decay (η = $η_slow)")
println("  Fast decay (η = $η_fast)")
println()
println("Autocorrelation comparison for C[1,1]:")
println("lag    slow-memory     fast-memory")
println("-----------------------------------")
for i in eachindex(lags)
    lag = lags[i]
    println(
        rpad(lag,6), " ",
        rpad(round(ac_slow[i][2], digits=4), 15),
        round(ac_fast[i][2], digits=4)
    )
end

println()
println("Interpretation:")
println("  • Larger η (slower decay) ⇒ stronger temporal persistence.")
println("  • Smaller η (faster decay) ⇒ faster decorrelation.")
println("  • Memory parameter directly controls effective non-Markovianity.")
println()
println(" Memory effects demo completed successfully.")

