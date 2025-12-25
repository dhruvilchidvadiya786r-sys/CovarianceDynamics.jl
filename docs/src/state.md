# State Representation (`state.jl`)

## Purpose

The `state.jl` file defines **how the system state is represented,
validated, and accessed** throughout CovarianceDynamics.jl.

It acts as the bridge between:
- abstract mathematical objects (covariance, memory)
- flat numerical vectors required by SciML solvers

This file is the **single source of truth** for state handling.

---

## What is the state?

The lifted system state consists of three components:

\[
(C,\; \psi,\; I)
\]

where:
- \(C\) is a symmetric positive-definite covariance matrix
- \(\psi\) is a nonnegative flux variable
- \(I\) is a nonnegative memory variable

These components are stored together in the `CovMemoryState` struct.

---

## Why a structured state is necessary

SciML solvers operate on flat vectors, but:
- covariance matrices have geometric structure
- memory variables have invariants
- theoretical analysis relies on matrix operations

`state.jl` separates **representation** from **dynamics**, allowing:
- clean mathematics
- safe numerical interfacing
- invariant checking
- diagnostic access

---

## Flattening and unflattening

Two complementary interfaces are provided:

- `flatten_state(state)`  
  Converts a structured state into a flat vector.

- `unflatten_state(u, p)`  
  Reconstructs the structured state from a flat vector.

These are the **only allowed mechanisms** for conversion.
No other file may reinterpret the state layout.

---

## Internal accessors

To avoid duplicated indexing logic, the following accessors are defined:

- `get_covariance(u, p)`
- `get_flux(u, p)`
- `get_memory(u, p)`

All drift, diffusion, and callback code must use these functions.

This eliminates indexing errors and ensures consistency.

---

## SPD projection

The function `project_to_spd` provides a **numerical safeguard**
that projects a matrix back onto the SPD cone by eigenvalue clipping.

Important:
- This is **not part of the mathematical model**
- It is used only when numerical discretization errors occur
- Its use is explicit and optional (via callbacks)

---

## Lyapunov function

The Lyapunov function

\[
V(C,\psi,I) = \mathrm{tr}(C) + \mathrm{tr}(C^{-1}) + \psi + I
\]

is defined here because:
- it depends only on the state
- it is used both theoretically and numerically
- it must be consistent everywhere

Diagnostics and analysis rely on this definition.

---

## What does NOT belong in this file

The following are intentionally excluded:

- drift equations
- stochastic diffusion
- numerical solvers
- callbacks
- diagnostics

Those belong in later layers of the architecture.

---

## Position in the architecture

