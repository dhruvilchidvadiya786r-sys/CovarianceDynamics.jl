
"""
state.jl

State representation and invariant-handling for CovarianceDynamics.jl.

This file defines:
- the lifted state container (covariance, flux, memory)
- flattening and unflattening logic
- safe accessors for SciML solvers
- SPD projection utilities
- Lyapunov function used in theoretical analysis

This file contains NO drift logic, NO diffusion logic,
and NO solver construction.
"""

# ============================================================
# 1. State Container
# ============================================================

"""
    CovMemoryState

Structured representation of the lifted system state.

Fields
------
C : covariance matrix (SPD)
ψ : flux variable (nonnegative)
I : memory variable (nonnegative)
"""
struct CovMemoryState{T<:Real}
    C::Matrix{T}
    ψ::T
    I::T
end


"""
Inner constructor enforcing structural invariants.
"""
function CovMemoryState(
    C::AbstractMatrix{T},
    ψ::T,
    I::T
) where {T<:Real}
    @assert size(C,1) == size(C,2) "Covariance must be square"
    @assert issymmetric(C) "Covariance must be symmetric"
    @assert ψ ≥ zero(T) "Flux ψ must be nonnegative"
    @assert I ≥ zero(T) "Memory I must be nonnegative"
    return CovMemoryState{T}(Matrix(C), ψ, I)
end


# ============================================================
# 2. State Dimension
# ============================================================

"""
    state_dimension(p)

Return the dimension of the flattened state vector.
"""
state_dimension(p::CovMemoryParams) = p.n^2 + 2


# ============================================================
# 3. Flatten / Unflatten Interface
# ============================================================

"""
    flatten_state(state)

Convert structured state into a flat vector suitable
for SciML solvers.
"""
function flatten_state(state::CovMemoryState{T}) where {T}
    return vcat(vec(state.C), state.ψ, state.I)
end


"""
    unflatten_state(u, p)

Convert a flat state vector back into a structured state.
"""
function unflatten_state(
    u::AbstractVector{T},
    p::CovMemoryParams{T}
) where {T}
    n = p.n
    C = reshape(u[1:n^2], n, n)
    ψ = u[n^2 + 1]
    I = u[n^2 + 2]
    return CovMemoryState(Matrix(Symmetric(C)), ψ, I)
end


# ============================================================
# 4. Internal Accessors (SINGLE SOURCE OF TRUTH)
# ============================================================

"""
    get_covariance(u, p)

Extract covariance matrix from flattened state.
"""
function get_covariance(
    u::AbstractVector{T},
    p::CovMemoryParams{T}
) where {T}
    n = p.n
    C = reshape(u[1:n^2], n, n)
    return Symmetric(C)
end


"""
    get_flux(u, p)

Extract flux variable ψ from flattened state.
"""
function get_flux(
    u::AbstractVector{T},
    p::CovMemoryParams{T}
) where {T}
    return u[p.n^2 + 1]
end


"""
    get_memory(u, p)

Extract memory variable I from flattened state.
"""
function get_memory(
    u::AbstractVector{T},
    p::CovMemoryParams{T}
) where {T}
    return u[p.n^2 + 2]
end


# ============================================================
# 5. SPD Projection (Numerical Safeguard)
# ============================================================

"""
    symmetrize(C)

Return the symmetric part of a matrix.
"""
symmetrize(C::AbstractMatrix) = (C + C') / 2


"""
    project_to_spd(C; ϵ = 1e-10)

Project a symmetric matrix onto the SPD cone by
clipping eigenvalues.

This is a NUMERICAL safeguard, not a modeling assumption.
"""
function project_to_spd(
    C::AbstractMatrix{T};
    ϵ::T = T(1e-10)
) where {T<:Real}
    Cs = symmetrize(C)
    E = eigen(Symmetric(Cs))
    λ = max.(E.values, ϵ)
    return E.vectors * Diagonal(λ) * E.vectors'
end


# ============================================================
# 6. State Validation
# ============================================================

"""
    check_state(state)

Check whether a structured state satisfies invariants.
"""
function check_state(state::CovMemoryState)
    return is_spd(state.C) && state.ψ ≥ 0 && state.I ≥ 0
end


"""
    check_state(u, p)

Check invariants directly from flattened state.
"""
function check_state(
    u::AbstractVector{T},
    p::CovMemoryParams{T}
) where {T}
    return check_state(unflatten_state(u, p))
end


# ============================================================
# 7. Lyapunov Function
# ============================================================

"""
    lyapunov(state)

Compute the Lyapunov function used in theoretical analysis:

    V(C,ψ,I) = tr(C) + tr(C⁻¹) + ψ + I
"""
function lyapunov(state::CovMemoryState)
    return tr(state.C) + tr(inv(state.C)) + state.ψ + state.I
end


"""
    lyapunov(u, p)

Lyapunov function evaluated on flattened state.
"""
function lyapunov(
    u::AbstractVector{T},
    p::CovMemoryParams{T}
) where {T}
    return lyapunov(unflatten_state(u, p))
end
