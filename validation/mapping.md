# Theory–Code–Validation Mapping

This document provides a **structured mapping between the conceptual model,
its implementation in code, and the validation evidence** contained in the
repository.

Its purpose is to ensure that:
- every conceptual component of the model is implemented explicitly,
- every implemented component is validated,
- and no validation exists without a corresponding conceptual target.

This file completes the validation layer by making the **logic of correctness
traceable end-to-end**.

---

## 1. Conceptual Model Overview

At a high level, `CovarianceDynamics.jl` implements a stochastic dynamical system
for covariance matrices with **memory effects**, formulated as:

- a covariance-valued stochastic process constrained to the SPD cone,
- augmented by auxiliary variables to represent non-Markovian memory,
- lifted to a finite-dimensional Markovian system for numerical integration.

The model consists of the following conceptual components:

1. SPD-valued covariance dynamics
2. Memory variables and integral states
3. Markovian lifting of non-Markovian dynamics
4. Stochastic forcing and numerical integration
5. Long-time and finite-time behavior

Each component is mapped below to:
- implementation location, and
- validation evidence.

---

## 2. Mapping: Concept → Implementation → Validation

### 2.1 SPD Covariance Manifold

**Concept**  
The primary state variable is a symmetric positive definite (SPD) covariance
matrix. Valid trajectories must remain within the SPD cone.

**Implementation**
- Covariance stored explicitly as a flattened matrix state
- Symmetry enforced by construction
- Dynamics formulated to respect SPD structure in continuous time

**Code Location**
- `src/` (core dynamics)
- State extraction logic used throughout experiments and tests

**Validation Evidence**
- `test/test_spd_invariance.jl`
- `experiments/projection_vs_no_projection.jl`
- `experiments/long_time_run.jl`

**Validated Properties**
- Symmetry preservation
- Strict positive definiteness in benign regimes
- No silent projection or clipping

---

### 2.2 Memory Variables (ψ) and Integral State (I)

**Concept**  
Non-Markovian effects are represented via auxiliary memory variables that encode
temporal dependence and drive an integral state.

**Implementation**
- Auxiliary variables appended to the state vector
- Explicit coupling between covariance, memory, and integral variables

**Code Location**
- `covmemory_problem(...)` construction
- Parameter struct defining memory decay and coupling

**Validation Evidence**
- `test/test_markov_lift.jl`
- `experiments/mixing_rate_estimation_advanced.jl`

**Validated Properties**
- Correct state dimension
- Nontrivial evolution of auxiliary variables
- Causal ψ → I coupling

---

### 2.3 Markovian Lifting

**Concept**  
The original non-Markovian dynamics are reformulated as a finite-dimensional
Markovian system to enable numerical simulation.

**Implementation**
- Augmented state vector `(C, ψ, I)`
- Single SDE system solved by standard SDE solvers

**Code Location**
- `covmemory_problem(...)`

**Validation Evidence**
- `test/test_markov_lift.jl`

**Validated Properties**
- Correct lifting dimension
- Active auxiliary dynamics
- Semantic correctness of the lift

---

### 2.4 Stochastic Forcing and Discretization

**Concept**  
The system is driven by stochastic noise and integrated numerically using
explicit SDE solvers.

**Implementation**
- Noise terms defined explicitly
- Integration via solvers from `DifferentialEquations.jl`
- Default use of Euler–Maruyama for diagnostics

**Code Location**
- Solver calls in `experiments/` and `examples/`

**Validation Evidence**
- `test/test_reproducibility.jl`
- `experiments/solver_comparison.jl`

**Validated Properties**
- Deterministic reproducibility under fixed RNG seeds
- Correct stochastic sensitivity
- Regime-dependent solver accuracy

---

### 2.5 Stability and Boundedness

**Concept**  
Well-posed dynamics should remain bounded and free of numerical explosion in
realistic regimes.

**Implementation**
- No explicit stabilizing projection
- Stability emerges from formulation and parameter choices

**Code Location**
- Core dynamics
- Diagnostic scripts

**Validation Evidence**
- `test/test_lyapunov.jl`
- `experiments/long_time_run.jl`

**Validated Properties**
- Finite Lyapunov-type functionals
- No explosive growth
- Stable long-time behavior in benign regimes

---

### 2.6 Memory and Mixing Behavior

**Concept**  
Memory parameters should influence temporal correlations and effective mixing
behavior.

**Implementation**
- Memory decay parameter explicitly controls auxiliary dynamics
- Observable extracted from covariance entries

**Code Location**
- Mixing diagnostics in `experiments/`

**Validation Evidence**
- `experiments/mixing_rate_estimation.jl`
- `experiments/mixing_rate_estimation_advanced.jl`

**Validated Properties**
- Autocorrelation decay
- Regime-dependent mixing behavior
- Finite-time memory effects

---

### 2.7 Stress and Failure Modes

**Concept**  
Numerical methods have limits; these limits should be understood and documented.

**Implementation**
- Explicit stress diagnostics with extreme parameters
- No attempt to hide or correct failures

**Code Location**
- `experiments/stress_test.jl`

**Validation Evidence**
- Documented SPD violations under extreme regimes
- Clear identification of solver limitations

---

## 3. Completeness Check

The table below summarizes coverage:

| Conceptual Component | Implemented | Validated |
|--------------------|-------------|-----------|
| SPD covariance structure | ✓ | ✓ |
| Memory variables | ✓ | ✓ |
| Markovian lifting | ✓ | ✓ |
| Stability (finite-time) | ✓ | ✓ |
| Reproducibility | ✓ | ✓ |
| Solver behavior | ✓ | ✓ |
| Stress limits | ✓ | ✓ |

No conceptual component exists without validation, and no validation exists
without a conceptual target.

---

## 4. Role of This Mapping

This mapping exists to ensure that:

- reviewers can audit claims efficiently,
- contributors understand where validation lives,
- future extensions can identify what must be re-validated.

It explicitly prevents:
- unvalidated features,
- accidental overclaiming,
- divergence between theory and implementation.

---

## 5. Summary

This document establishes that `CovarianceDynamics.jl` is:

- conceptually coherent,
- correctly implemented,
- empirically validated,
- and transparent about its scope.

Together with `validation_manifest.md`, `guarantees.md`, and `limitations.md`,
this mapping completes the **validation contract** of the repository.

