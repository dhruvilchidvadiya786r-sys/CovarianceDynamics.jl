# Deterministic Drift (`drift.jl`)

## Purpose

The `drift.jl` file defines the **deterministic dynamics** of the lifted
covariance–flux–memory system implemented in CovarianceDynamics.jl.

It contains the exact vector field corresponding to the mathematical
model studied in the accompanying theoretical work.

This file is the **only place** where deterministic time evolution
is defined.

---

## Mathematical Model

The lifted system state is:

\[
(C_t,\; \psi_t,\; I_t)
\]

The deterministic drift is given by:

\[
\begin{aligned}
\frac{dC_t}{dt} &= -\lambda (C_t - \bar{C})
                 + \psi_t\, T(C_t)
                 + I_t\, K(C_t), \\
\frac{d\psi_t}{dt} &= -\beta\, \psi_t, \\
\frac{dI_t}{dt} &= -\eta\, I_t + \psi_t.
\end{aligned}
\]

Each term has a distinct interpretation and role in the dynamics.

---

## Covariance Drift

### Mean Reversion

The term
\[
-\lambda (C - \bar{C})
\]
pulls the covariance toward a long-run target \( \bar{C} \),
preventing uncontrolled growth.

---

### Transport Term

The transport contribution
\[
\psi\, T(C)
\]
redistributes covariance mass along interaction pathways induced
by the Laplacian operator.

This term is modulated by the flux variable \( \psi \).

---

### Curvature Feedback

The curvature term
\[
I\, K(C)
\]
introduces global feedback proportional to the aggregate interaction
strength accumulated through memory.

This is the mechanism by which past interactions influence present
covariance structure.

---

## Flux Drift

The flux variable follows a deterministic decay:

\[
\frac{d\psi}{dt} = -\beta \psi.
\]

This is the deterministic part of a CIR-type process.
Stochastic excitation is added in `diffusion.jl`.

---

## Memory Drift

The memory variable evolves according to:

\[
\frac{dI}{dt} = -\eta I + \psi.
\]

This equation implements the **finite-dimensional Markovian lift**
of an exponential memory kernel.

The memory variable aggregates past flux values with exponential decay.

---

## Structured vs Flattened Drift

Two representations of the drift are provided:

### Structured Drift
- `structured_drift(state, p)`
- Returns a `CovMemoryState`
- Used for diagnostics and analysis

### Flattened Drift
- `drift!(du, u, p, t)`
- Required by SciML solvers
- Operates on flat vectors only

Both representations are mathematically identical.

---

## What does NOT belong in this file

The following are intentionally excluded:

- stochastic diffusion terms
- numerical solvers
- callbacks or projections
- diagnostics
- plotting or logging

This strict separation ensures correctness and maintainability.

---

## Position in the Architecture


