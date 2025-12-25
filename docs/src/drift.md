# Deterministic Drift (`drift.jl`)

## Purpose

The `drift.jl` file defines the **deterministic dynamics** of the lifted covariance–flux–memory system in **CovarianceDynamics.jl**.  
It contains the exact vector field corresponding to the mathematical model presented in the accompanying theoretical work.  
This file is the **only place** where the deterministic time evolution is defined.

## Mathematical Model

The lifted system state is $(C_t, \psi_t, I_t)$.

The deterministic drift is given by the following system of ordinary differential equations:

$$
\begin{aligned}
\frac{d C_t}{dt} &= -\lambda (C_t - \bar{C}) + \psi_t \, T(C_t) + I_t \, K(C_t), \\
\frac{d \psi_t}{dt} &= -\beta \, \psi_t, \\
\frac{d I_t}{dt} &= -\eta \, I_t + \psi_t.
\end{aligned}
$$

Each term has a distinct interpretation and role in the dynamics.

## Covariance Drift

### Mean Reversion

The term
$$
-\lambda (C_t - \bar{C})
$$
pulls the covariance toward a long-run target $\bar{C}$, preventing uncontrolled growth.

### Transport Term

The transport contribution
$$
\psi_t \, T(C_t)
$$
redistributes covariance mass along interaction pathways induced by the Laplacian operator. This term is modulated by the flux variable $\psi_t$.

### Curvature Feedback

The curvature term
$$
I_t \, K(C_t)
$$
introduces global feedback proportional to the aggregate interaction strength accumulated through memory. This is the mechanism by which past interactions influence the present covariance structure.

## Flux Drift

The flux variable follows a deterministic decay:
$$
\frac{d \psi_t}{dt} = -\beta \, \psi_t.
$$
This is the deterministic part of a CIR-type process. Stochastic excitation is added separately in `diffusion.jl`.

## Memory Drift

The memory variable evolves according to:
$$
\frac{d I_t}{dt} = -\eta \, I_t + \psi_t.
$$
This equation implements the **finite-dimensional Markovian lift** of an exponential memory kernel. The memory variable aggregates past flux values with exponential decay.

## Structured vs Flattened Drift

Two equivalent representations of the drift are provided:

### Structured Drift
- Function: `structured_drift(state, p, t)`
- Returns a `CovMemoryState`
- Used primarily for diagnostics and theoretical analysis

### Flattened Drift
- Function: `drift!(du, u, p, t)`
- In-place form required by SciML solvers (DifferentialEquations.jl)
- Operates exclusively on flattened vectors

Both representations are **mathematically identical**.

## What Does NOT Belong in This File

The following are intentionally excluded to maintain separation of concerns:

- Stochastic diffusion terms (defined in `diffusion.jl`)
- Numerical solvers or integration logic
- Callbacks or manifold projections (in `callbacks.jl`)
- Diagnostic computations or logging (in `diagnostics.jl`)
- Plotting or visualization code

This strict separation ensures correctness, testability, and long-term maintainability.

## Position in the Architecture

`drift.jl` sits at the core of the dynamical system definition. It is used by `problem.jl` to construct the `ODEProblem` or `SDEProblem` and is the single source of truth for the deterministic vector field.
