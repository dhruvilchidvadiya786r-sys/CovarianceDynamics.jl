
"""
callbacks.jl

Numerical safety callbacks for CovarianceDynamics.jl.

This file defines OPTIONAL numerical enforcement mechanisms that:
- detect violations of structural invariants
- project the system back into admissible state space

These callbacks are NOT part of the mathematical model.
They exist solely to protect against discretization error.

All callbacks are opt-in and can be disabled by the user.
"""

using SciMLBase
using LinearAlgebra

# ============================================================
# 1. SPD Violation Detection
# ============================================================

"""
    spd_violation(u, t, integrator)

Return `true` if the covariance matrix violates SPD constraints.

This condition triggers projection only when:
- symmetry is lost
- minimum eigenvalue is non-positive
"""
function spd_violation(u, t, integrator)
    p = integrator.p
    C = get_covariance(u, p)

    # Fast symmetry check
    if !issymmetric(C)
        return true
    end

    # Eigenvalue check (expensive, but safe)
    λmin = minimum(eigvals(Symmetric(C)))
    return λmin ≤ zero(eltype(λmin))
end


# ============================================================
# 2. SPD Enforcement
# ============================================================

"""
    enforce_spd!(integrator)

Project the covariance matrix back onto the SPD cone and
enforce nonnegativity of auxiliary variables.

This modifies the solver state in-place.
"""
function enforce_spd!(integrator)
    p = integrator.p
    u = integrator.u

    C = get_covariance(u, p)
    ψ = get_flux(u, p)
    I = get_memory(u, p)

    # Project covariance
    Cproj = project_to_spd(C)

    # Enforce auxiliary nonnegativity
    ψ = max(ψ, zero(eltype(ψ)))
    I = max(I, zero(eltype(I)))

    integrator.u .= flatten_state(CovMemoryState(Cproj, ψ, I))

    return nothing
end


"""
    spd_callback()

Create a DiscreteCallback enforcing SPD invariance.
"""
function spd_callback()
    return DiscreteCallback(
        spd_violation,
        enforce_spd!;
        save_positions = (false, false)
    )
end


# ============================================================
# 3. Auxiliary Variable Violation Detection
# ============================================================

"""
    auxiliary_violation(u, t, integrator)

Return `true` if ψ or I becomes negative.
"""
function auxiliary_violation(u, t, integrator)
    p = integrator.p
    ψ = get_flux(u, p)
    I = get_memory(u, p)

    return ψ < zero(eltype(ψ)) || I < zero(eltype(I))
end


# ============================================================
# 4. Auxiliary Variable Enforcement
# ============================================================

"""
    enforce_auxiliary!(integrator)

Clamp auxiliary variables ψ and I to zero if they become negative.
"""
function enforce_auxiliary!(integrator)
    p = integrator.p
    u = integrator.u

    C = get_covariance(u, p)
    ψ = max(get_flux(u, p), zero(eltype(u)))
    I = max(get_memory(u, p), zero(eltype(u)))

    integrator.u .= flatten_state(CovMemoryState(C, ψ, I))

    return nothing
end


"""
    auxiliary_callback()

Create a DiscreteCallback enforcing nonnegativity of ψ and I.
"""
function auxiliary_callback()
    return DiscreteCallback(
        auxiliary_violation,
        enforce_auxiliary!;
        save_positions = (false, false)
    )
end


# ============================================================
# 5. Combined Safety Callback
# ============================================================

"""
    safety_callbacks()

Return a CallbackSet enforcing all numerical invariants.

This is the DEFAULT numerical safeguard used in simulations.
"""
function safety_callbacks()
    return CallbackSet(
        spd_callback(),
        auxiliary_callback()
    )
end


# ============================================================
# 6. Invariant Violation Diagnostics
# ============================================================

"""
    violates_invariants(u, p)

Check whether a flattened state violates any invariants.
"""
function violates_invariants(
    u::AbstractVector{T},
    p::CovMemoryParams{T}
) where {T}

    C = get_covariance(u, p)
    ψ = get_flux(u, p)
    I = get_memory(u, p)

    return (!issymmetric(C)) ||
           (minimum(eigvals(Symmetric(C))) ≤ zero(T)) ||
           (ψ < zero(T)) ||
           (I < zero(T))
end
