"""
operators.jl

Deterministic matrix operators for CovarianceDynamics.jl.

This file defines all operators that act directly on the covariance
matrix C, independent of time evolution, noise, or solver state.

Included operators:
- interaction Laplacian L(C)
- transport operator T(C)
- curvature feedback operator K(C)

These operators are purely algebraic and have no side effects.
"""

# ============================================================
# 1. Laplacian Interface
# ============================================================

"""
    laplacian(C, p)

Compute the interaction Laplacian L(C) associated with the
covariance matrix C and model parameters p.

This function dispatches on the Laplacian operator stored in p.
"""
function laplacian(
    C::AbstractMatrix{T},
    p::CovMemoryParams{T}
) where {T}
    return laplacian(C, p.laplacian)
end


# ============================================================
# 2. Correlation-Induced Laplacian
# ============================================================

"""
    laplacian(C, op::CorrelationLaplacian)

Construct a correlation-induced graph Laplacian.

Steps:
1. Convert covariance matrix C to correlation matrix R
2. Construct a weighted interaction graph from |Rᵢⱼ|
3. Return the symmetric graph Laplacian L = D - W

The resulting operator is symmetric and positive semidefinite.
"""
function laplacian(
    C::AbstractMatrix{T},
    op::CorrelationLaplacian{T}
) where {T}

    n = size(C, 1)
    @assert size(C, 2) == n "Covariance matrix must be square"

    # --------------------------------------------------------
    # Step 1: Covariance → Correlation
    # --------------------------------------------------------
    d = sqrt.(diag(C))
    invd = similar(d)

    @inbounds for i in 1:n
        invd[i] = d[i] > zero(T) ? inv(d[i]) : zero(T)
    end

    Dinv = Diagonal(invd)
    R = Dinv * C * Dinv

    # --------------------------------------------------------
    # Step 2: Weight Matrix
    # --------------------------------------------------------
    W = Matrix{T}(undef, n, n)
    α = op.α

    @inbounds for i in 1:n, j in 1:n
        if i == j
            W[i, j] = zero(T)
        else
            w = abs(R[i, j])
            W[i, j] = op.normalize ? α * w / (one(T) + w) : α * w
        end
    end

    # --------------------------------------------------------
    # Step 3: Graph Laplacian
    # --------------------------------------------------------
    deg = vec(sum(W, dims = 2))
    L = Diagonal(deg) - W

    return Symmetric(L)
end


# ============================================================
# 3. Transport Operator
# ============================================================

"""
    transport(C, p)

Compute the transport operator

    T(C) = C L(C) + L(C) C

This operator redistributes covariance mass along the
interaction structure induced by L(C).
"""
function transport(
    C::AbstractMatrix{T},
    p::CovMemoryParams{T}
) where {T}
    L = laplacian(C, p)
    return C * L + L * C
end


# ============================================================
# 4. Curvature Feedback Operator
# ============================================================

"""
    curvature(C, p)

Compute the curvature feedback operator

    K(C) = tr(C L(C)) · C

This term introduces global feedback proportional to the
aggregate interaction strength.
"""
function curvature(
    C::AbstractMatrix{T},
    p::CovMemoryParams{T}
) where {T}
    L = laplacian(C, p)
    return tr(C * L) * C
end


# ============================================================
# 5. Operator Diagnostics (Optional, Non-Dynamical)
# ============================================================

"""
    operator_bounds(C, p)

Return operator norm diagnostics for L(C), T(C), and K(C).

Used for numerical verification of theoretical growth bounds.
"""
function operator_bounds(
    C::AbstractMatrix{T},
    p::CovMemoryParams{T}
) where {T}

    L = laplacian(C, p)
    T_op = transport(C, p)
    K_op = curvature(C, p)

    return (
        laplacian_norm = opnorm(L),
        transport_norm = opnorm(T_op),
        curvature_norm = opnorm(K_op)
    )
end


"""
    check_operator_symmetry(C, p)

Verify symmetry preservation of all operators.
"""
function check_operator_symmetry(
    C::AbstractMatrix{T},
    p::CovMemoryParams{T}
) where {T}

    L = laplacian(C, p)
    T_op = transport(C, p)
    K_op = curvature(C, p)

    return issymmetric(L) && issymmetric(T_op) && issymmetric(K_op)
end


# ============================================================
# 6. Growth Diagnostics (Theory ↔ Numerics)
# ============================================================

"""
    growth_diagnostics(C, p)

Estimate relative growth rates of operators with respect to ‖C‖.

These quantities are used to numerically validate polynomial
growth assumptions in Lyapunov analysis.
"""
function growth_diagnostics(
    C::AbstractMatrix{T},
    p::CovMemoryParams{T}
) where {T}

    normC = opnorm(C)
    bounds = operator_bounds(C, p)

    return (
        laplacian_growth = bounds.laplacian_norm / (one(T) + normC),
        transport_growth = bounds.transport_norm / (one(T) + normC),
        curvature_growth = bounds.curvature_norm / (one(T) + normC^2)
    )
end
