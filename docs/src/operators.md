# Deterministic Operators (`operators.jl`)

## Purpose

The `operators.jl` file defines all **deterministic matrix operators**
that act directly on the covariance matrix \( C \).

These operators encode **structural interactions** between components
of the covariance without introducing time dependence, noise, or
numerical side effects.

They are the mathematical core of the model’s geometry.

---

## Why operators are separated from dynamics

In stochastic models, mixing operators with drift or diffusion leads to:
- duplicated logic
- hidden assumptions
- untestable components
- broken invariants

`operators.jl` isolates **pure algebraic structure** so that:
- mathematical properties are transparent
- operators can be tested independently
- alternative dynamics can reuse the same geometry

---

## The Interaction Laplacian

### Definition

The interaction Laplacian \( L(C) \) is constructed by:
1. Converting the covariance matrix to a correlation matrix
2. Building a weighted interaction graph
3. Returning the symmetric graph Laplacian

\[
L(C) = D(C) - W(C)
\]

where weights depend on absolute correlations.

### Properties

- symmetric
- positive semidefinite
- data-dependent
- invariant under scaling of \( C \)

---

## Transport Operator

### Definition

\[
T(C) = C L(C) + L(C) C
\]

### Interpretation

The transport operator redistributes covariance mass along
interaction pathways induced by \( L(C) \).

It preserves symmetry and reflects structured interaction dynamics.

---

## Curvature Feedback Operator

### Definition

\[
K(C) = \mathrm{tr}(C L(C)) \cdot C
\]

### Interpretation

This term introduces **global feedback** proportional to the total
interaction energy.

It couples local interaction structure with global covariance scale.

---

## Diagnostic Operators

Several non-dynamical diagnostics are provided:

- operator norms
- symmetry checks
- growth rate estimates

These are used to:
- verify theoretical growth assumptions
- detect numerical instability
- validate Lyapunov estimates

They **do not** affect the model dynamics.

---

## What does NOT belong in this file

The following are intentionally excluded:

- time evolution
- drift equations
- stochastic diffusion
- solver interfaces
- callbacks or projections

Those belong in later layers.

---

## Position in the Architecture


