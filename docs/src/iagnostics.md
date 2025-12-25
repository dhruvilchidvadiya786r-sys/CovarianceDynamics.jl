# Diagnostics and Analysis (`diagnostics.jl`)

## Purpose

The `diagnostics.jl` file provides **read-only analysis tools**
for validating numerical simulations of CovarianceDynamics.jl.

It connects:
- theoretical guarantees (Lyapunov stability, ergodicity)
- empirical numerical behavior
- solver-independent diagnostics

This file never modifies state and never interacts with solvers.

---

## Why diagnostics are separated

Mixing diagnostics with dynamics causes:
- hidden feedback loops
- solver-dependent behavior
- irreproducible results

Separating diagnostics ensures:
- scientific integrity
- reproducibility
- clean benchmarking
- fair theory–numerics comparison

---

## Lyapunov Diagnostics

The Lyapunov function defined in `state.jl` is evaluated along
solution trajectories using:

```julia
lyapunov_trajectory(sol, p)
