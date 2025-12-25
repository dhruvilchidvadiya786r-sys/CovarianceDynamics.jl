# State Representation (`state.jl`)

## Purpose

The `state.jl` file defines **how the system state is represented, validated, and accessed** throughout **CovarianceDynamics.jl**.  
It acts as the bridge between:

- Abstract mathematical objects (covariance, memory)  
- Flat numerical vectors required by SciML solvers

This file is the **single source of truth** for state handling.

## What is the State?

The lifted system state consists of three components:

$$
(C, \; \psi, \; I)
$$

where:

- $C$ is a symmetric positive-definite covariance matrix  
- $\psi$ is a nonnegative flux variable  
- $I$ is a nonnegative memory variable  

These components are stored together in the `CovMemoryState` struct.

## Why a Structured State is Necessary

SciML solvers operate on flat vectors, but:

- Covariance matrices have geometric structure (SPD manifold)  
- Memory variables have invariants (nonnegativity)  
- Theoretical analysis relies on matrix operations  

`state.jl` separates **representation** from **dynamics**, enabling:

- Clean mathematics  
- Safe numerical interfacing  
- Invariant checking  
- Diagnostic access  

## Flattening and Unflattening

Two complementary interfaces are provided:

- `flatten_state(state)`  
  Converts a structured state into a flat vector.

- `unflatten_state(u, p)`  
  Reconstructs the structured state from a flat vector.

These are the **only allowed mechanisms** for conversion.  
No other file may reinterpret the state layout.

## Internal Accessors

To avoid duplicated indexing logic, the following accessors are defined:

- `get_covariance(u, p)`  
- `get_flux(u, p)`  
- `get_memory(u, p)`  

All drift, diffusion, and callback code **must** use these functions.  
This eliminates indexing errors and ensures consistency.

## SPD Projection

The function `project_to_spd` provides a **numerical safeguard** that projects a matrix back onto the SPD cone by eigenvalue clipping.

**Important:**

- This is **not part of the mathematical model**  
- It is used only when numerical discretization errors occur  
- Its use is explicit and optional (via callbacks)

## Lyapunov Function

The Lyapunov function is defined as:

$$
V(C, \psi, I) = \tr(C) + \tr(C^{-1}) + \psi + I
$$

It is defined here because:

- It depends only on the state  
- It is used both theoretically and numerically  
- It must be consistent everywhere  

Diagnostics and analysis rely on this exact definition.

## What Does NOT Belong in This File

The following are intentionally excluded to maintain separation of concerns:

- Drift equations (`drift.jl`)  
- Stochastic diffusion (`diffusion.jl`)  
- Numerical solvers (`problem.jl`)  
- Callbacks (`callbacks.jl`)  
- Diagnostics (`diagnostics.jl`)  

Those belong in their respective dedicated layers.

## Position in the Architecture

`state.jl` forms the **foundational representation layer**. It is imported by **all other modules** and provides the essential conversion functions and accessors that ensure type safety, consistency, and geometric awareness throughout the package.
