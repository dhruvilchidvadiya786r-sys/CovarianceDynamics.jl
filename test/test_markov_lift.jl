###############################################################################
# test_markov_lift.jl
#
# Unit test: Markov lift structure
#
# Purpose:
#   Verify that the non-Markovian covariance dynamics are correctly lifted
#   to a finite-dimensional Markovian system via auxiliary memory variables.
#
# This test checks:
#   • Correct state dimension (C, ψ, I)
#   • Nontrivial evolution
#   • Effective ψ → I coupling
###############################################################################

using Test
using Random
using LinearAlgebra
using DifferentialEquations
using CovarianceDynamics

# ---------------------------------------------------------------------
# Reproducibility
# ---------------------------------------------------------------------
Random.seed!(2024)

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
    η   = 1.5   # finite memory decay
)

tspan = (0.0, 1.0)

# Non-zero ψ₀ drives immediate evolution of the integral variable I
prob = covmemory_problem(params, tspan; ψ0 = 0.5, I0 = 0.0)

sol = solve(prob, EM(); dt = 1e-3)

# ---------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------
@testset "Markov lift structure" begin
    # State dimension: covariance + memory + integral
    @test length(prob.u0) == n^2 + 2

    # Nontrivial evolution
    @test norm(sol.u[end] - sol.u[1]) > 0.01
    @test all(isfinite, sol.u[end])

    # Memory → integral coupling
    I_initial = prob.u0[end]
    I_final   = sol.u[end][end]
    @test I_final > I_initial + 0.05
end
