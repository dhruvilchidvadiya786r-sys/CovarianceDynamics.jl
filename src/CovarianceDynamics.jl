"""
    module CovarianceDynamics

CovarianceDynamics.jl provides a modular, geometry-preserving framework
for stochastic covariance dynamics with memory.

The package implements a finite-dimensional Markovian lift of non-Markovian
covariance flows evolving on the manifold of symmetric positive-definite (SPD)
matrices. It is designed for mathematical rigor, numerical stability, and
compatibility with the SciML ecosystem.

This file defines the top-level module, includes internal components in a
strict dependency order, and exposes the public API. No model logic is
implemented here.
"""
module CovarianceDynamics

# ============================================================
# Standard Libraries
# ============================================================

using LinearAlgebra
using Statistics

# ============================================================
# External Dependencies
# ============================================================

using SciMLBase

# ============================================================
# Internal Modules (ORDER IS SEMANTICALLY IMPORTANT)
# ============================================================

# Core type system and model parameters
include("types.jl")

# State representation, invariants, and Lyapunov structure
include("state.jl")

# Deterministic operators acting on covariance matrices
include("operators.jl")

# Deterministic drift of the lifted stochastic system
include("drift.jl")

# Stochastic diffusion (noise structure)
include("diffusion.jl")

# Optional numerical safety mechanisms (callbacks)
include("callbacks.jl")

# SciML-compatible problem constructor
include("problem.jl")

# Diagnostics and analysis utilities
include("diagnostics.jl")

# ============================================================
# Public API
# ============================================================

export
    # Core types
    CovMemoryParams,
    CovMemoryState,

    # State utilities
    flatten_state,
    unflatten_state,
    state_dimension,
    get_covariance,
    get_flux,
    get_memory,
    project_to_spd,
    lyapunov,

    # Operators (advanced usage)
    laplacian,
    transport,
    curvature,

    # SciML interface
    covmemory_problem,

    # Diagnostics
    lyapunov_trajectory,
    min_eigen_trajectory,
    condition_number_trajectory,
    time_average,
    ergodicity_error,
    consistency_report

end # module CovarianceDynamics

