###############################################################################
# test_reproducibility.jl
#
# Unit test: Stochastic reproducibility
#
# Purpose:
#   Verify that CovarianceDynamics simulations are:
#     • deterministic under identical RNG seeds
#     • stochastic under different RNG seeds
#
# This ensures CI stability and correct RNG usage.
###############################################################################

using Test
using Random
using LinearAlgebra
using DifferentialEquations
using CovarianceDynamics

# ---------------------------------------------------------------------
# Problem setup
# ---------------------------------------------------------------------
n = 2
C̄ = Matrix{Float64}(I, n, n)
U  = Matrix{Float64}(I, n, n)

params = CovMemoryParams(
    n;
    λ   = 1.0,
    C̄   = C̄,
    β   = 1.0,
    σψ  = 0.2,
    ε   = 0.1,
    U   = U,
    η   = 1.0
)

tspan = (0.0, 1.0)
dt = 1e-3

# ---------------------------------------------------------------------
# Helper: run simulation with a given seed
# ---------------------------------------------------------------------
function run_with_seed(seed::Integer)
    Random.seed!(seed)
    prob = covmemory_problem(params, tspan)
    sol  = solve(prob, EM(); dt = dt)
    return sol.u[end]
end

# ---------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------
@testset "Reproducibility" begin
    u1 = run_with_seed(12345)
    u2 = run_with_seed(12345)
    u3 = run_with_seed(54321)

    # Same seed → identical result
    @test u1 ≈ u2 atol = 1e-10

    # Different seed → different result
    @test u1 ≉ u3 atol = 1e-10
end
