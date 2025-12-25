###############################################################################
# test_markov_lift.jl
#
# Structural verification of the Markovian lift used to represent
# non-Markovian covariance dynamics.
#
# What is tested:
#   1) Correct state dimension of the lifted system
#   2) Proper inclusion and evolution of memory variables
#   3) Consistency of drift evaluation (finite, deterministic)
#
# What is NOT tested:
#   - Long-time behavior
#   - Ergodicity or mixing rates
#   - Quantitative convergence
###############################################################################

using Test
using Random
using LinearAlgebra
using DifferentialEquations
using CovarianceDynamics

# -------------------------------------------------------------------
# Determinism
# -------------------------------------------------------------------
Random.seed!(2024)

# -------------------------------------------------------------------
# Minimal setup
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
    η   = 1.5
)

# -------------------------------------------------------------------
# Problem construction
# -------------------------------------------------------------------
tspan = (0.0, 0.1)
prob = covmemory_problem(params, tspan)

# -------------------------------------------------------------------
# State dimension checks
# -------------------------------------------------------------------
@testset "Markov lift structure" begin

    # 1) State vector dimension
    #
    # Layout:
    #   - n^2 entries for covariance matrix C
    #   - m entries for memory variables (m = memory dimension)
    #
    expected_dim = params.n^2 + CovarianceDynamics.memory_dimension(params)

    @test length(prob.u0) == expected_dim

    # -------------------------------------------------------------------
    # 2) Drift evaluation consistency
    # -------------------------------------------------------------------
    #
    # Evaluate drift at initial state
    #
    du = similar(prob.u0)
    CovarianceDynamics.covmemory_drift!(du, prob.u0, params, 0.0)

    # All drift components must be finite
    @test all(isfinite, du)

    # Memory components must not be identically zero
    mem_start = params.n^2 + 1
    mem_block = du[mem_start:end]

    @test any(abs.(mem_block) .> 0)

    # -------------------------------------------------------------------
    # 3) Short-time evolution of memory variables
    # -------------------------------------------------------------------
    sol = solve(prob, EM(); dt = 1e-3)

    u_start = sol.u[1]
    u_end   = sol.u[end]

    mem_start = params.n^2 + 1

    mem_initial = u_start[mem_start:end]
    mem_final   = u_end[mem_start:end]

    # Memory variables must evolve (not frozen)
    @test norm(mem_final - mem_initial) > 0

end

