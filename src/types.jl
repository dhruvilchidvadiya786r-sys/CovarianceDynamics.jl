"""
types.jl

Core type definitions for CovarianceDynamics.jl.

This file defines the complete type system and parameter containers
for the covariance–memory dynamics model. It contains only immutable
types, abstract interfaces, and constructors.

No numerical logic, no drift, no diffusion, and no solver code
is implemented here.
"""

# ============================================================
# Abstract Type Hierarchy
# ============================================================

"""
Abstract supertype for all covariance dynamics models.
"""
abstract type AbstractCovarianceModel end


"""
Abstract supertype for memory kernels.

Memory kernels define how historical flux values influence
the present covariance dynamics.
"""
abstract type AbstractMemoryKernel end


"""
Abstract supertype for interaction / Laplacian operators.

These operators encode structured interactions induced
by the covariance matrix.
"""
abstract type AbstractLaplacianOperator end


# ============================================================
# Memory Kernel Types
# ============================================================

"""
    ExponentialMemory(η)

Exponential memory kernel defined by

    Iₜ = ∫₀ᵗ exp(-η (t - s)) ψₛ ds

This kernel admits an exact finite-dimensional Markovian lift
via the ODE:

    dI = -η I dt + ψ dt
"""
struct ExponentialMemory{T<:Real} <: AbstractMemoryKernel
    η::T
end


# ============================================================
# Interaction / Laplacian Operator Types
# ============================================================

"""
    CorrelationLaplacian(α, normalize)

Correlation-induced Laplacian operator.

Given a covariance matrix C, this operator:
1. Converts C to a correlation matrix
2. Builds a weighted interaction graph
3. Returns a symmetric graph Laplacian L(C)

Parameters
----------
α : interaction strength
normalize : whether to normalize correlations
"""
struct CorrelationLaplacian{T<:Real} <: AbstractLaplacianOperator
    α::T
    normalize::Bool
end


# ============================================================
# Core Parameter Container
# ============================================================

"""
    CovMemoryParams

Immutable parameter container for the lifted covariance–flux–memory model.

This struct stores all parameters required to define the model:
- covariance dimension
- mean-reversion structure
- flux process parameters
- noise structure
- memory kernel
- interaction operator

The parameter container is immutable and type-stable, making it
safe for use with SciML solvers.
"""
struct CovMemoryParams{
    T<:Real,
    M<:AbstractMemoryKernel,
    L<:AbstractLaplacianOperator
} <: AbstractCovarianceModel

    # Dimension
    n::Int

    # Covariance mean reversion
    λ::T
    C̄::Matrix{T}

    # Flux process (CIR-type)
    β::T
    σψ::T

    # Covariance noise
    ε::T
    U::Matrix{T}

    # Structural components
    memory::M
    laplacian::L
end


# ============================================================
# Parameter Validation
# ============================================================

"""
    validate_params(p::CovMemoryParams)

Validate structural and mathematical correctness of model parameters.
"""
function validate_params(p::CovMemoryParams)
    @assert p.n > 0 "Dimension n must be positive"
    @assert size(p.C̄) == (p.n, p.n) "C̄ must be n×n"
    @assert issymmetric(p.C̄) "C̄ must be symmetric"
    @assert p.λ > 0 "λ must be positive"
    @assert p.β > 0 "β must be positive"
    @assert p.σψ ≥ 0 "σψ must be nonnegative"
    @assert p.ε ≥ 0 "ε must be nonnegative"
    @assert size(p.U) == (p.n, p.n) "U must be n×n"
    @assert issymmetric(p.U) "U must be symmetric"
    return true
end


# ============================================================
# User-Facing Constructor
# ============================================================

"""
    CovMemoryParams(n; kwargs...)

Convenience constructor for the exponential-memory covariance model.

Keyword Arguments
-----------------
λ        : covariance mean-reversion rate
C̄        : long-run covariance target
β        : flux mean-reversion rate
σψ       : flux noise strength
ε        : covariance noise strength
U        : covariance noise geometry matrix
η        : memory decay rate
α        : interaction strength (default: 1.0)
normalize: normalize correlations (default: true)
"""
function CovMemoryParams(
    n::Int;
    λ::Real,
    C̄::AbstractMatrix,
    β::Real,
    σψ::Real,
    ε::Real,
    U::AbstractMatrix,
    η::Real,
    α::Real = 1.0,
    normalize::Bool = true
)
    T = promote_type(
        typeof(λ), typeof(β), typeof(σψ),
        typeof(ε), typeof(η), eltype(C̄)
    )

    params = CovMemoryParams{T,
        ExponentialMemory{T},
        CorrelationLaplacian{T}
    }(
        n,
        T(λ),
        Matrix{T}(C̄),
        T(β),
        T(σψ),
        T(ε),
        Matrix{T}(U),
        ExponentialMemory{T}(T(η)),
        CorrelationLaplacian{T}(T(α), normalize)
    )

    validate_params(params)
    return params
end

