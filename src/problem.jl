"""
problem.jl

SciML problem construction for CovarianceDynamics.jl.

This file defines the canonical interface that converts the
mathematical model (drift + diffusion + state representation)
into a SciML-compatible SDEProblem.

No mathematics, no operators, and no diagnostics are defined here.
This file is strictly an interface layer.
"""

using SciMLBase

# ============================================================
# 1. Initial State Construction
# ============================================================

"""
    initial_state(p; C0, ψ0, I0)

Construct a valid initial CovMemoryState.

Keyword Arguments
-----------------
C0 : initial covariance matrix (SPD)
ψ0 : initial flux (nonnegative)
I0 : initial memory (nonnegative)
"""
function initial_state(
    p::CovMemoryParams{T};
    C0::AbstractMatrix{T},
    ψ0::T = zero(T),
    I0::T = zero(T)
) where {T}

    state = CovMemoryState(C0, ψ0, I0)
    return flatten_state(state)
end


# ============================================================
# 2. Problem Constructor
# ============================================================

"""
    covmemory_problem(p, u0, tspan; kwargs...)

Construct an SDEProblem for the covariance–memory dynamics.

Arguments
---------
p     : CovMemoryParams
u0    : initial state (flattened vector or CovMemoryState)
tspan : (t₀, t₁)

Keyword Arguments
-----------------
callback : SciML callback or CallbackSet (default: safety_callbacks())
noise    : whether to include stochastic diffusion (default: true)

Returns
-------
SDEProblem compatible with DifferentialEquations.jl
"""
function covmemory_problem(
    p::CovMemoryParams{T},
    u0,
    tspan::Tuple{<:Real,<:Real};
    callback = safety_callbacks(),
    noise::Bool = true
) where {T}

    # --------------------------------------------------------
    # Normalize initial state
    # --------------------------------------------------------
    u0_vec = if u0 isa CovMemoryState
        flatten_state(u0)
    else
        u0
    end

    @assert length(u0_vec) == state_dimension(p)

    # --------------------------------------------------------
    # Select diffusion (deterministic vs stochastic)
    # --------------------------------------------------------
    diffusion_fun = noise ? diffusion! : nothing

    # --------------------------------------------------------
    # Construct SciML problem
    # --------------------------------------------------------
    return SDEProblem(
        drift!,
        diffusion_fun,
        u0_vec,
        tspan,
        p;
        callback = callback
    )
end


# ============================================================
# 3. Convenience Constructors
# ============================================================

"""
    covmemory_problem(p, tspan; kwargs...)

Construct an SDEProblem using default initial conditions.

Defaults
--------
C0 = p.C̄
ψ0 = 0
I0 = 0
"""
function covmemory_problem(
    p::CovMemoryParams{T},
    tspan::Tuple{<:Real,<:Real};
    C0 = p.C̄,
    ψ0 = zero(T),
    I0 = zero(T),
    kwargs...
) where {T}

    u0 = initial_state(p; C0 = C0, ψ0 = ψ0, I0 = I0)
    return covmemory_problem(p, u0, tspan; kwargs...)
end


# ============================================================
# 4. Deterministic Problem Constructor
# ============================================================

"""
    covmemory_ode_problem(p, u0, tspan; kwargs...)

Construct a deterministic ODEProblem by disabling diffusion.
"""
function covmemory_ode_problem(
    p::CovMemoryParams{T},
    u0,
    tspan::Tuple{<:Real,<:Real};
    callback = safety_callbacks()
) where {T}

    u0_vec = u0 isa CovMemoryState ? flatten_state(u0) : u0

    return ODEProblem(
        drift!,
        u0_vec,
        tspan,
        p;
        callback = callback
    )
end

