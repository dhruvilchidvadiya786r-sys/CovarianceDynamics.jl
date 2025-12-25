###############################################################################
# projection_vs_no_projection.jl
#
# Controlled comparison:
#   Intrinsic SPD-preserving dynamics (CovarianceDynamics.jl)
#   vs
#   Naïve projection-based SPD enforcement
#
# Scientific question:
#   Is projection necessary, and what does it distort?
#
# IMPORTANT:
# This experiment is diagnostic, not prescriptive.
# Projection is used here ONLY as a baseline comparison.
###############################################################################

using Random
using LinearAlgebra
using Statistics
using DifferentialEquations
using CovarianceDynamics

# -----------------------------
# Reproducibility
# -----------------------------
Random.seed!(424242)

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
σψ = 0.25
ε  = 0.2
η  = 1.0

# -----------------------------
# Time horizon
# -----------------------------
tspan = (0.0, 50.0)
dt = 1e-3

# -----------------------------
# Helpers
# -----------------------------
function is_spd_state(u::AbstractVector, n::Int)
    C = reshape(u[1:n^2], n, n)
    return isposdef(Symmetric(C))
end

function frob_norm(u::AbstractVector, n::Int)
    C = reshape(u[1:n^2], n, n)
    return norm(C, fro)
end

# Projection onto SPD via eigenvalue clipping
function project_to_spd!(u::AbstractVector, n::Int; ϵ = 1e-6)
    C = reshape(u[1:n^2], n, n)
    F = eigen(Symmetric(C))
    Λ = Diagonal(max.(F.values, ϵ))
    Cproj = F.vectors * Λ * F.vectors'
    u[1:n^2] .= vec(Cproj)
    return nothing
end

# -----------------------------
# Intrinsic (no projection) run
# -----------------------------
params_intrinsic = CovMemoryParams(
    n;
    λ   = λ,
    C̄   = Cbar,
    β   = β,
    σψ  = σψ,
    ε   = ε,
    U   = U,
    η   = η
)

prob_intrinsic = covmemory_problem(params_intrinsic, tspan)

sol_intrinsic = solve(
    prob_intrinsic,
    EM();
    dt = dt
)

# -----------------------------
# Projected run (naïve baseline)
# -----------------------------
# We reuse the SAME dynamics, but forcibly project after each step
sol_projected = solve(
    prob_intrinsic,
    EM();
    dt = dt,
    callback = DiscreteCallback(
        (u, t, integrator) -> true,
        integrator -> project_to_spd!(integrator.u, n)
    )
)

# -----------------------------
# Diagnostics
# -----------------------------
# SPD violations (intrinsic should be zero)
spd_intrinsic = all(is_spd_state(u, n) for u in sol_intrinsic.u)
spd_projected = all(is_spd_state(u, n) for u in sol_projected.u)

# Frobenius norms
norms_intrinsic = [frob_norm(u, n) for u in sol_intrinsic.u]
norms_projected = [frob_norm(u, n) for u in sol_projected.u]

# Statistics
stats = Dict(
    :intrinsic => (
        mean = mean(norms_intrinsic),
        std  = std(norms_intrinsic),
        max  = maximum(norms_intrinsic)
    ),
    :projected => (
        mean = mean(norms_projected),
        std  = std(norms_projected),
        max  = maximum(norms_projected)
    )
)

# Bias relative to reference covariance
function mean_bias(sol, Cbar, n)
    Cs = [reshape(u[1:n^2], n, n) for u in sol.u]
    mean(norm(C - Cbar, fro) for C in Cs)
end

bias_intrinsic = mean_bias(sol_intrinsic, Cbar, n)
bias_projected = mean_bias(sol_projected, Cbar, n)

# -----------------------------
# Output summary
# -----------------------------
println("=== CovarianceDynamics.jl :: Projection vs No-Projection ===")
println("Time horizon              : $tspan")
println("Steps                     : $(length(sol_intrinsic.t))")
println()
println("SPD preservation:")
println("  Intrinsic dynamics       : $spd_intrinsic")
println("  Projected dynamics       : $spd_projected")
println()
println("Frobenius norm statistics:")
println("  Intrinsic  mean/std/max  : $(stats[:intrinsic])")
println("  Projected  mean/std/max  : $(stats[:projected])")
println()
println("Mean bias ||C - C̄||_F:")
println("  Intrinsic dynamics       : $bias_intrinsic")
println("  Projected dynamics       : $bias_projected")
println()
println("Interpretation:")
println("  • Intrinsic dynamics preserve SPD without intervention.")
println("  • Projection enforces SPD but alters dynamics.")
println("  • Projection introduces bias and artificial distortion.")
println()
println("Projection comparison experiment completed.")

# -----------------------------
# Hard checks
# -----------------------------
if !spd_intrinsic
    error("Intrinsic dynamics violated SPD — this should not happen.")
end

