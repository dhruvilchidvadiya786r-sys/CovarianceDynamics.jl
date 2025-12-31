###############################################################################
# test_lyapunov.jl
#
# Unit test: Lyapunov-type boundedness
#
# Purpose:
#   Verify that a natural quadratic Lyapunov-type functional remains
#   finite and uniformly bounded in a benign regime.
#
# IMPORTANT:
#   • This is NOT a proof of stability.
#   • This test checks empirical boundedness only.
#   • Noise is expected to move the system away from equilibrium.
###############################################################################

using Test
using Random
using LinearAlgebra
using Statistics
using DifferentialEquations
using CovarianceDynamics

# ---------------------------------------------------------------------
# Reproducibility
# ---------------------------------------------------------------------
Random.seed!(1234)

# ---------------------------------------------------------------------
# Problem setup
# ---------------------------------------------------------------------
n = 2
C̄ = Matrix{Float64}(I, n, n)
U  = Matrix{Float64}(I, n, n)

# Fast-memory, small-step regime chosen for boundedness testing
params = CovMemoryParams(
    n;
    λ   = 1.0,
    C̄   = C̄,
    β   = 1.0,
    σψ  = 0.2,
    ε   = 0.1,
    U   = U,
    η   = 100.0
)

tspan = (0.0, 0.5)
dt = 1e-3

# ---------------------------------------------------------------------
# Solve SDE
# ---------------------------------------------------------------------
prob = covmemory_problem(params, tspan)
sol  = solve(prob, EM(); dt = dt)

# ---------------------------------------------------------------------
# Lyapunov-type functional
# ---------------------------------------------------------------------
function lyapunov(u::AbstractVector, n::Int, C̄::AbstractMatrix)
    C = reshape(u[1:n^2], n, n)
    return norm(C - C̄)^2
end

V_vals = [lyapunov(u, n, C̄) for u in sol.u]

# ---------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------
@testset "Lyapunov-type boundedness" begin
    # Finite and nonnegative
    @test all(isfinite, V_vals)
    @test all(v -> v ≥ 0.0, V_vals)

    # Uniform boundedness relative to typical scale
    Vmean = mean(V_vals)
    Vmax  = maximum(V_vals)
    @test Vmax ≤ 10.0 * (Vmean + eps())

    # No explosive growth over time
    mid = length(V_vals) ÷ 2
    V_early = mean(V_vals[1:mid])
    V_late  = mean(V_vals[mid+1:end])
    @test V_late ≤ 5.0 * V_early + eps()
end
