"""
diffusion.jl

Stochastic diffusion (noise structure) for the lifted covariance–flux–memory system.

This file defines all stochastic components of the model:
- geometry-preserving covariance noise
- CIR-type noise for the flux variable
- zero diffusion for the memory variable

It provides both:
- structured diffusion (for diagnostics and testing)
- SciML-compatible diffusion! interface

No deterministic drift, no callbacks, and no solver construction
are implemented here.
"""

# ============================================================
# 1. Covariance Diffusion (Geometry-Preserving Noise)
# ============================================================

"""
    covariance_diffusion(C, p)

Compute the covariance diffusion matrix Σ(C).

Mathematically:
    Σ(C) = ε ( C^{1/2} U + U C^{1/2} )

This noise:
- preserves symmetry
- is tangent to the SPD manifold
- maintains positive definiteness at the continuous level
"""
function covariance_diffusion(
    C::AbstractMatrix{T},
    p::CovMemoryParams{T}
) where {T}

    # Symmetric square root via Cholesky
    F = cholesky(Symmetric(C)).L
    return p.ε * (F * p.U + p.U * F)
end


# ============================================================
# 2. Flux Diffusion (CIR-Type Noise)
# ============================================================

"""
    flux_diffusion(ψ, p)

Compute the diffusion coefficient for the flux variable ψ.

Mathematically:
    dψ = σψ √ψ dB

This choice preserves nonnegativity of ψ at the continuous level.
"""
function flux_diffusion(
    ψ::T,
    p::CovMemoryParams{T}
) where {T}

    return p.σψ * sqrt(max(ψ, zero(T)))
end


# ============================================================
# 3. Structured Diffusion (State-Level)
# ============================================================

"""
    structured_diffusion(state, p)

Return the stochastic diffusion as a structured CovMemoryState.

Used for diagnostics, testing, and theoretical verification.
"""
function structured_diffusion(
    state::CovMemoryState{T},
    p::CovMemoryParams{T}
) where {T}

    ΣC = covariance_diffusion(state.C, p)
    σψ = flux_diffusion(state.ψ, p)
    σI = zero(T)

    return CovMemoryState(ΣC, σψ, σI)
end


# ============================================================
# 4. SciML Diffusion Interface
# ============================================================

"""
    diffusion!(du, u, p, t)

SciML-compatible in-place diffusion function.

Maps the flattened state vector u to the flattened
diffusion vector du.
"""
function diffusion!(
    du::AbstractVector{T},
    u::AbstractVector{T},
    p::CovMemoryParams{T},
    t
) where {T}

    n = p.n
    @assert length(u) == n^2 + 2
    @assert length(du) == n^2 + 2

    # --------------------------------------------------------
    # Unpack state
    # --------------------------------------------------------
    C = reshape(view(u, 1:n^2), n, n)
    ψ = u[n^2 + 1]

    # --------------------------------------------------------
    # Compute diffusion components
    # --------------------------------------------------------
    ΣC = covariance_diffusion(C, p)
    σψ = flux_diffusion(ψ, p)
    σI = zero(T)

    # --------------------------------------------------------
    # Pack result
    # --------------------------------------------------------
    du .= flatten_state(CovMemoryState(ΣC, σψ, σI))

    return nothing
end


# ============================================================
# 5. Diffusion Diagnostics (Non-Dynamical)
# ============================================================

"""
    diffusion_diagnostics(state, p)

Return basic norms of diffusion components for diagnostics.
"""
function diffusion_diagnostics(
    state::CovMemoryState{T},
    p::CovMemoryParams{T}
) where {T}

    d = structured_diffusion(state, p)

    return (
        covariance_norm = opnorm(d.C),
        flux_abs = abs(d.ψ),
        memory_abs = abs(d.I)
    )
end

