# Executive Overview

`CovarianceDynamics.jl` is a research-oriented Julia package for simulating **stochastic covariance dynamics on the manifold of symmetric positive definite (SPD) matrices**, with explicit support for **memory effects** via a Markovian lift of non-Markovian processes.

This documentation provides a complete and transparent account of:
- the mathematical structure of the model,
- the numerical methods used,
- the invariants that are preserved,
- and the empirical evidence supporting long-time stability and ergodicity.

---

## What is implemented

The package implements a family of **stochastic differential equations (SDEs)** of the form

- state includes a covariance matrix \( C_t \in \mathcal{S}^n_{++} \),
- auxiliary memory variables encode non-Markovian effects,
- the combined system is evolved as a **Markovian lift** compatible with standard SDE solvers.

The implementation is fully compatible with the **SciML ecosystem** and exposes dynamics through standard `SDEProblem` interfaces.

---

## Why this problem is difficult

Covariance matrices do not form a vector space.  
As a result:

- additive noise can destroy positive definiteness,
- numerical drift can break symmetry,
- long-time simulations are often unstable,
- memory effects are rarely handled without violating geometry.

Most existing approaches either:
- ignore memory, or
- sacrifice geometric correctness.

This package is designed to **avoid both failures**.

---

## Core design principles

The implementation is guided by four non-negotiable principles:

1. **Geometric correctness**  
   The covariance matrix remains symmetric and positive definite at all simulated times.

2. **Memory-aware dynamics**  
   Non-Markovian effects are introduced through a controlled Markovian lift rather than ad-hoc history dependence.

3. **Numerical transparency**  
   All invariants and qualitative behaviors are verified numerically and explicitly documented.

4. **Reproducibility**  
   All reported results can be reproduced from fixed parameter sets and solver configurations.

---

## Validated properties (numerical)

The following properties have been **explicitly verified through numerical experiments**:

- Preservation of the SPD manifold
- Long-time boundedness of trajectories
- Convergence of time averages
- Existence of a stationary regime
- Slow decay of correlations induced by memory
- Tunable mixing behavior via the memory parameter

These results are documented in detail in the `experiments` and `diagnostics` sections.

---

## What is not claimed

To maintain rigor and credibility, the following are **not claimed**:

- No formal proof of ergodicity or mixing rates
- No closed-form invariant measure
- No claim of optimal discretization schemes
- No claim of large-scale performance optimization

All conclusions are clearly identified as **numerical evidence**, not theorems.

---

## Intended use

This package is intended for:

- exploratory research in stochastic covariance modeling,
- numerical investigation of memory effects,
- methodological development within the SciML ecosystem,
- and as a foundation for future theoretical analysis.

It is **not** intended as a drop-in production covariance estimator.

---

## How this documentation is structured

- **Motivation & context** → `motivation.md`, `background.md`
- **Mathematical formulation** → `theory.md`, `model.md`
- **Geometric structure** → `geometry.md`, `invariants.md`
- **Numerical methods** → `numerics.md`
- **Diagnostics & measurements** → `diagnostics.md`
- **Reproducible experiments** → `experiments.md`
- **Limitations & roadmap** → `limitations.md`, `roadmap.md`
- **Reproducibility details** → `reproducibility.md`

---

## Project status

The project is under active development with a focus on:
- correctness,
- clarity,
- and extensibility.

Future work will prioritize theoretical analysis, solver improvements, and higher-dimensional experiments.

---

*This executive overview defines the scope and guarantees of the project.  
Each subsequent section elaborates on a specific aspect in full technical detail.*

