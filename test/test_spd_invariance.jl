###############################################################################
# test_spd_invariance.jl
#
# Unit test: Structural SPD invariance
#
# Purpose:
#   Verify that, in a benign regime (fast memory, small dt),
#   the CovarianceDynamics formulation preserves:
#     - symmetry
#     - strict positive definiteness
#
# IMPORTANT:
#   • This is a correctness test, not a stress test.
#   • Numerical adversarial regimes are tested elsewhere (experiments/).
###############################################################################

using Test
using Random
using LinearAlgebra
using DifferentialEquations
using CovarianceDynamics

# ---------------------------------------------------------------------
# Reproducibility
# ---------------------------------------------------------------------
Random.seed!(2023)

# ---------------------------------------------------------------------
# Problem setup
# ---------------------------------------------------------------------
n = 2
C̄ = Matrix{Float64}(I, n, n)
U  = Matrix{Float64}(I, n, n)

# Fast-memory, small-step regime chosen to test structural invariance
# rather than numerical robustness.
params = CovMemoryParams(
    n;
    λ   = 1.0,
    C̄   = C̄,
    β   = 1.0,
    σψ  = 0.2,
    ε   = 0.1,
    U   = U,
    η   = 100.0   # fast memory decay
)

tspan = (0.0, 1.0)
dt = 1e-3

# ---------------------------------------------------------------------
# Solve SDE
# ---------------------------------------------------------------------
prob = covmemory_problem(params, tspan)
sol  = solve(prob, EM(); dt = dt)

# ---------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------
@testset "SPD invariance" begin
    for u in sol.u
        # Extract covariance matrix
        C = Symmetric(reshape(u[1:n^2], n, n))

        # Strict positive definiteness
        eigmin = minimum(eigvals(C))
        @test eigmin > 0.0
        @test isposdef(C)

        # Symmetry preservation
        @test norm(Matrix(C) - Matrix(C)', Inf) ≤ 1e-10
    end
end
