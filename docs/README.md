
# CovarianceDynamics.jl — Documentation

This documentation describes the **theoretical motivation**, **mathematical structure**, and **numerical validation** of `CovarianceDynamics.jl`, a Julia package for **stochastic covariance dynamics on the SPD manifold with memory**.

The goal of this documentation is to make the design decisions, guarantees, and limitations of the package **fully transparent and reproducible**.

---

## What this package does

`CovarianceDynamics.jl` implements **stochastic differential equations (SDEs)** whose state includes a **covariance matrix evolving on the manifold of symmetric positive definite (SPD) matrices**, optionally coupled to **memory variables** via a Markovian lift of non-Markovian dynamics.

In particular, the package provides:

- Stochastic covariance flows that **preserve symmetry and positive definiteness**
- A **Markovian lift** formulation for incorporating **long-memory effects**
- SciML-compatible problem definitions (`SDEProblem`)
- Diagnostic tools for studying **ergodicity, mixing, and memory persistence**
- Numerically validated invariants and long-time stability

---

## Why this is nontrivial

Covariance matrices do **not** form a vector space.  
Naïve stochastic models often fail by:
- destroying positive definiteness,
- violating symmetry,
- or becoming unstable over long time horizons.

In addition, most existing covariance models are **purely Markovian**, which prevents them from capturing **persistent temporal dependence** observed in many applications.

This package addresses both issues simultaneously by:
1. Respecting the **geometry of the SPD manifold**, and  
2. Incorporating **memory through a mathematically controlled Markovian lift**.

---

## What is guaranteed (numerically)

The following properties have been **explicitly tested and validated numerically**:

- **SPD invariance**: covariance matrices remain symmetric and positive definite for all simulated times
- **Long-time boundedness**: trajectories do not explode or collapse
- **Existence of an invariant regime**: time averages converge
- **Ergodicity with memory**: correlations decay slowly but eventually vanish
- **Controllable mixing**: memory strength directly affects correlation decay rates

These guarantees are demonstrated in the `experiments` and `diagnostics` sections.

---

## What is *not* claimed

To maintain scientific rigor, the following are **not claimed at this stage**:

- No formal proof of ergodicity or mixing rates
- No closed-form invariant distribution
- No claims of optimal numerical schemes
- No claim of production-level optimization

All results are clearly identified as **numerical evidence**, not theorems.

---

## How to navigate this documentation

- **Executive overview** → `index.md`  
- **Motivation and problem gap** → `motivation.md`  
- **Mathematical background** → `background.md`, `theory.md`  
- **Exact model equations & code mapping** → `model.md`  
- **Geometry and invariants** → `geometry.md`, `invariants.md`  
- **Numerical methods** → `numerics.md`  
- **Diagnostics & measurements** → `diagnostics.md`  
- **Reproducible experiments** → `experiments.md`  
- **Limitations & roadmap** → `limitations.md`, `roadmap.md`  
- **Reproducibility details** → `reproducibility.md`  

---

## Intended audience

This documentation is written for:
- applied mathematicians
- researchers in stochastic analysis
- SciML contributors
- reviewers evaluating open-source research software
- advanced users interested in covariance dynamics with memory

It assumes familiarity with:
- stochastic differential equations
- linear algebra and covariance matrices
- basic numerical simulation concepts

---

## Status

This project is under **active development**.  
The current focus is on:
- correctness,
- clarity,
- reproducibility,
- and extensibility.

Feedback, issues, and contributions are welcome.

---

*For citation information, see the main repository `CITATION.cff`.*
