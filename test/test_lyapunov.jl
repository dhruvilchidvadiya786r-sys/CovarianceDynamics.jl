###############################################################################
# test_lyapunov.jl
#
# Short-time Lyapunov-type stability test for CovarianceDynamics.jl
#
# Invariant tested:
#   The covariance dynamics do not exhibit explosive growth over a short
#   deterministic time window.
#
# IMPORTANT:
#   - This is NOT a proof of Lyapunov stability.
#   - This test only guards against regressions that introduce blow-up,
#     NaNs, or unbounded growth at short times.
###############################################################################

using Test
using Random
using LinearAlgebra
using DifferentialEquations
using CovarianceDynamics

# -------------------------------------------------------------------
# Determinism
# -------------------------------------------------------------------
Random.seed!(1234)

# -------------------------------------------------------------------
# Minimal problem setup
# -------------------------------------------------------------------
n = 2
Cbar = Matrix{Float64}(I, n, n)
U    = Matrix{Float64}(I, n, n)

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

# Short time horizon (tests must be fast)
tspan = (0.0, 0.5)
dt = 1e-3

# -------------------------------------------------------------------
# Construct and solve
# -------------------------------------------------------------------
prob = covmemory_problem(params, tspan)

sol = solve(
    prob,
    EM();
    dt = dt
)

# -------------------------------------------------------------------
# Lyapunov-like functional
# V(C) = ||C - C̄||_F^2
# -------------------------------------------------------------------
function lyapunov(u::AbstractVector, n::Int, Cbar::AbstractMatrix)
    C = reshape(u[1:n^2], n, n)
    return norm(C - Cbar, fro)^2
end

V_vals = [lyapunov(u, n, Cbar) for u in sol.u]

# -------------------------------------------------------------------
# Assertions (invariant-focused, not numeric)
# -------------------------------------------------------------------

@testset "Lyapunov-type boundedness" begin

    # 1) No NaN or Inf values
    @test all(isfinite, V_vals)

    # 2) Values remain non-negative
    @test all(v -> v ≥ 0.0, V_vals)

    # 3) No explosive growth over short horizon
    #
    # We allow stochastic fluctuation but forbid runaway growth.
    #
    V0 = first(V_vals)
    Vmax = maximum(V_vals)

    @test Vmax ≤ 100.0 * max(V0, eps())

    # 4) No monotone explosion trend
    #
    # Compare early and late averages
    mid = length(V_vals) ÷ 2
    V_early = mean(V_vals[1:mid])
    V_late  = mean(V_vals[mid+1:end])

    @test V_late ≤ 10.0 * max(V_early, eps())

end

