
"""
drift.jl

Deterministic drift of the lifted covariance–flux–memory system.

This file defines the full deterministic part of the SDE governing:
- covariance evolution
- flux evolution
- memory evolution

It provides both:
- structured drift (for analysis and diagnostics)
- SciML-compatible drift! interface

No stochastic terms, no callbacks, and no solver construction
are implemented here.
"""

# ============================================================
# 1. Covariance Drift
# ============================================================

"""
    covariance_drift(C, ψ, I, p)

Compute the deterministic drift of the covariance matrix C.

Mathematically:
    dC/dt = -λ (C - C̄) + ψ · T(C) + I · K(C)

where:
- λ is the mean-reversion rate
- C̄ is the long-run covariance
- T(C) is the transport operator
- K(C) is the curvature feedback operator
"""
function covariance_drift(
    C::AbstractMatrix{T},
    ψ::T,
    I::T,
    p::CovMemoryParams{T}
) where {T}

    # Mean reversion toward long-run covariance
    drift = -p.λ * (C - p.C̄)

    # Transport contribution
    if ψ != zero(T)
        drift += ψ * transport(C, p)
    end

    # Curvature feedback contribution
    if I != zero(T)
        drift += I * curvature(C, p)
    end

    return drift
end


# ============================================================
# 2. Flux Drift (CIR Deterministic Part)
# ============================================================

"""
    flux_drift(ψ, p)

Deterministic drift of the flux variable ψ.

Mathematically:
    dψ/dt = -β ψ
"""
flux_drift(ψ::T, p::CovMemoryParams{T}) where {T} =
    -p.β * ψ


# ============================================================
# 3. Memory Drift
# ============================================================

"""
    memory_drift(ψ, I, p)

Drift of the memory variable I corresponding to
the exponential memory kernel.

Mathematically:
    dI/dt = -η I + ψ
"""
memory_drift(
    ψ::T,
    I::T,
    p::CovMemoryParams{T}
) where {T} =
    -p.memory.η * I + ψ


# ============================================================
# 4. Structured Drift (State-Level)
# ============================================================

"""
    structured_drift(state, p)

Return the deterministic drift as a structured CovMemoryState.

This representation is useful for:
- diagnostics
- theoretical verification
- testing and debugging
"""
function structured_drift(
    state::CovMemoryState{T},
    p::CovMemoryParams{T}
) where {T}

    dC = covariance_drift(state.C, state.ψ, state.I, p)
    dψ = flux_drift(state.ψ, p)
    dI = memory_drift(state.ψ, state.I, p)

    return CovMemoryState(dC, dψ, dI)
end


# ============================================================
# 5. SciML Drift Interface
# ============================================================

"""
    drift!(du, u, p, t)

SciML-compatible in-place drift function.

This function maps the flattened state vector u
to the flattened deterministic drift du.
"""
function drift!(
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
    C  = reshape(view(u, 1:n^2), n, n)
    ψ  = u[n^2 + 1]
    I  = u[n^2 + 2]

    # --------------------------------------------------------
    # Compute drift components
    # --------------------------------------------------------
    dC = covariance_drift(C, ψ, I, p)
    dψ = flux_drift(ψ, p)
    dI = memory_drift(ψ, I, p)

    # --------------------------------------------------------
    # Pack result
    # --------------------------------------------------------
    du .= flatten_state(CovMemoryState(dC, dψ, dI))

    return nothing
end
