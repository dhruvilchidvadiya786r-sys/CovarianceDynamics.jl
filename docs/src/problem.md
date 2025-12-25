# SciML Problem Interface (`problem.jl`)

## Purpose

The `problem.jl` file defines the **interface layer** between
the mathematical model implemented in CovarianceDynamics.jl
and the SciML ecosystem.

This file is responsible for:
- constructing valid initial states
- assembling drift and diffusion into SciML problems
- providing a stable user-facing entry point

No mathematics is defined here.

---

## Why a dedicated problem layer is necessary

Scientific models should not:
- depend directly on solver APIs
- mix mathematical logic with numerical infrastructure
- expose internal details to users

`problem.jl` isolates **solver-specific concerns** while preserving
a clean mathematical core.

---

## Initial State Construction

The function `initial_state` ensures that:
- covariance matrices are valid and symmetric
- auxiliary variables are nonnegative
- the flattened representation is consistent

This prevents silent errors at the start of simulations.

---

## Stochastic Problem Construction

The primary entry point is:

```julia
covmemory_problem(p, u0, tspan)

