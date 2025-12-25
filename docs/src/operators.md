# Deterministic Operators (`operators.jl`)

## Purpose

The `operators.jl` file defines all **deterministic matrix operators** that act directly on the covariance matrix $C$.  
These operators encode **structural interactions** between components of the covariance without introducing time dependence, noise, or numerical side effects.  
They form the mathematical core of the model’s geometry.

## Why Operators Are Separated from Dynamics

In stochastic models, mixing operators with drift or diffusion often leads to:

- duplicated logic
- hidden assumptions
- untestable components
- broken invariants

By isolating **pure algebraic structure** in `operators.jl`, we ensure that:

- mathematical properties remain transparent
- operators can be tested independently
- alternative dynamics can reuse the same geometry

## The Interaction Laplacian

### Definition

The interaction Laplacian $L(C)$ is constructed as follows:

1. Convert the covariance matrix to a correlation matrix  
2. Build a weighted interaction graph  
3. Return the symmetric graph Laplacian

$$
L(C) = D(C) - W(C)
$$

where the weights depend on absolute correlations.

### Properties

- Symmetric
- Positive semidefinite
- Data-dependent
- Invariant under scaling of $C$

## Transport Operator

### Definition

$$
T(C) = C \, L(C) + L(C) \, C
$$

### Interpretation

The transport operator redistributes covariance mass along interaction pathways induced by $L(C)$.  
It preserves symmetry and reflects structured interaction dynamics.

## Curvature Feedback Operator

### Definition

$$
K(C) = \tr\bigl(C \, L(C)\bigr) \cdot C
$$

### Interpretation

This term introduces **global feedback** proportional to the total interaction energy.  
It couples local interaction structure with the global covariance scale.

## Diagnostic Operators

Several non-dynamical diagnostic tools are provided, including:

- Operator norms
- Symmetry checks
- Growth rate estimates

These are used to:

- Verify theoretical growth assumptions
- Detect potential numerical instability
- Validate Lyapunov estimates

They **do not** affect the model dynamics.

## What Does NOT Belong in This File

The following are intentionally excluded to maintain separation of concerns:

- Time evolution or drift equations
- Stochastic diffusion terms
- Solver interfaces
- Callbacks or manifold projections

These belong in their respective dedicated files.

## Position in the Architecture

`operators.jl` provides the foundational geometric layer of the package. Its pure functions are imported by `drift.jl`, `diffusion.jl`, and `diagnostics.jl`, serving as the single source of truth for all interaction-induced algebraic operations on the covariance matrix.
