###############################################################################
# test_spd_invariance.jl
#
# Geometric invariance test for CovarianceDynamics.jl
#
# Invariant tested:
#   The covariance matrix C(t) remains symmetric positive definite (SPD)
#   for all times in the numerical simulation.
#
# Why this matters:
#   Loss of SPD implies:
#     - invalid covariance interpretation
#     - numerical instability
#     - physically meaningless results
#
# This test is strict, deterministic, and solver-agnostic.
###############################################################################

using Test
using Random
using LinearAlgebra
using DifferentialEquations
using CovarianceDynamics

# -------------------------------------------------------------------
# Determinism
# -------------------------------------------------------------------
Random.seed!(2023)

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

# Short-to-moderate time horizon
tspan = (0.0, 1.0)
dt = 1e-3

# -------------------------------------------------------------------
# Construct and solve
# -------------------------------------------------------------------
prob = covmemory_problem(params, tspan)
sol  = solve(prob, EM(); dt = dt)

# -------------------------------------------------------------------
# Helper: SPD check
# -------------------------------------------------------------------
function is_spd(u::AbstractVector, n::Int)
    C = reshape(u[1:n^2], n, n)
    return isposdef(Symmetric(C))
end

# -------------------------------------------------------------------
# Tests
# -------------------------------------------------------------------
@testset "SPD invariance" begin

    # 1) All covariance states are SPD
    @test all(u -> is_spd(u, n), sol.u)

    # 2) Eigenvalues are strictly positive (numerical safety)
    for u in sol.u
        C = reshape(u[1:n^2], n, n)
        λmin = minimum(eigvals(Symmetric(C)))
        @test λmin > 0.0
    end

    # 3) Symmetry is preserved numerically
    for u in sol.u
        C = reshape(u[1:n^2], n, n)
        @test norm(C - C', Inf) ≤ 1e-10
    end

end

