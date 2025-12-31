# Validation Manifest

This document provides a **complete, auditable mapping** between the claims made
by `CovarianceDynamics.jl` and the concrete validation evidence supporting them.

The goal of this manifest is **traceability**:
every validated property listed here points to an explicit test, experiment,
or diagnostic script already present in the repository.

No new computations are performed here.
This file serves as a **validation index**.

---

## 1. Scope of Validation

Validation in this project covers the following dimensions:

- Structural correctness
- Stability and boundedness
- Correct Markovian lifting of non-Markovian dynamics
- Reproducibility and determinism
- Long-time numerical behavior
- Memory and mixing dynamics
- Solver behavior and numerical regimes
- Stress limits and failure modes

Each category below lists:
- **What is validated**
- **How it is validated**
- **Where the evidence lives**

---

## 2. Structural Correctness

| Property | Description | Evidence Type | Location |
|--------|-------------|---------------|----------|
| Symmetry preservation | Covariance matrices remain symmetric | Unit test | `test/test_spd_invariance.jl` |
| Positive definiteness (SPD) | Covariance matrices remain strictly SPD in benign regimes | Unit test | `test/test_spd_invariance.jl` |
| Manifold consistency | State evolution respects the SPD cone | Unit test + diagnostics | `test/test_spd_invariance.jl`, `experiments/projection_vs_no_projection.jl` |
| State dimensionality | Lifted state has correct dimension (`C + ψ + I`) | Unit test | `test/test_markov_lift.jl` |

**Interpretation:**  
These checks ensure the mathematical structure of the model is implemented
correctly and that no algebraic invariants are violated due to coding errors.

---

## 3. Markovian Lift Correctness

| Property | Description | Evidence Type | Location |
|--------|-------------|---------------|----------|
| Correct state augmentation | Auxiliary memory variables are present | Unit test | `test/test_markov_lift.jl` |
| Nontrivial auxiliary dynamics | Lifted variables evolve over time | Unit test | `test/test_markov_lift.jl` |
| ψ → I coupling | Memory variable causally drives integral state | Unit test | `test/test_markov_lift.jl` |

**Interpretation:**  
These tests verify that the non-Markovian formulation is correctly realized
as a finite-dimensional Markovian system, and that auxiliary variables are
semantically meaningful rather than inert.

---

## 4. Stability and Boundedness

| Property | Description | Evidence Type | Location |
|--------|-------------|---------------|----------|
| Finite Lyapunov functional | Lyapunov-type quantity remains finite | Unit test | `test/test_lyapunov.jl` |
| Nonnegativity | Lyapunov functional is nonnegative | Unit test | `test/test_lyapunov.jl` |
| Uniform boundedness | No explosive growth over time | Unit test | `test/test_lyapunov.jl` |
| Long-time numerical stability | No drift or explosion over long horizons | Diagnostic | `experiments/long_time_run.jl` |

**Interpretation:**  
Stability claims are **empirical**, not theoretical, and are restricted to
well-specified regimes. No global or asymptotic stability proofs are claimed.

---

## 5. Reproducibility

| Property | Description | Evidence Type | Location |
|--------|-------------|---------------|----------|
| Determinism under fixed seed | Identical RNG seed yields identical results | Unit test | `test/test_reproducibility.jl` |
| Stochastic sensitivity | Different seeds yield different trajectories | Unit test | `test/test_reproducibility.jl` |
| CI safety | Tests are fast and deterministic | Unit test suite | `test/` |

**Interpretation:**  
These checks ensure that the package behaves correctly as stochastic software
and is safe for continuous integration environments.

---

## 6. Long-Time Behavior

| Property | Description | Evidence Type | Location |
|--------|-------------|---------------|----------|
| Long-horizon stability | Stable behavior over extended time intervals | Diagnostic | `experiments/long_time_run.jl` |
| Absence of drift | No systematic growth or decay | Diagnostic | `experiments/long_time_run.jl` |
| Persistent SPD | Positive definiteness maintained | Diagnostic | `experiments/long_time_run.jl` |

**Interpretation:**  
These diagnostics demonstrate robustness under prolonged simulation,
beyond what unit tests can reasonably cover.

---

## 7. Memory and Dynamical Behavior

| Property | Description | Evidence Type | Location |
|--------|-------------|---------------|----------|
| Autocorrelation decay | Temporal correlations decay over time | Diagnostic | `experiments/mixing_rate_estimation.jl` |
| Empirical mixing times | Finite-time mixing estimates | Diagnostic | `experiments/mixing_rate_estimation_advanced.jl` |
| Memory parameter control | Dynamics depend on memory decay parameter | Diagnostic | `experiments/mixing_rate_estimation_advanced.jl` |
| Non-Markovian effects | Memory influences observed dynamics | Diagnostic | `experiments/mixing_rate_estimation_advanced.jl` |

**Interpretation:**  
These results demonstrate that memory effects are **active and measurable**,
not merely auxiliary state variables.

---

## 8. Solver Behavior

| Property | Description | Evidence Type | Location |
|--------|-------------|---------------|----------|
| Solver comparison | EM vs higher-order SDE solvers | Diagnostic | `experiments/solver_comparison.jl` |
| Regime dependence | Solver accuracy depends on regime | Diagnostic | `experiments/solver_comparison.jl` |
| No universal solver claim | No solver is claimed optimal in all cases | Documentation | `experiments/solver_comparison.jl` |

**Interpretation:**  
Solver behavior is evaluated empirically and conservatively, without
overgeneralization.

---

## 9. Stress Testing and Failure Modes

| Property | Description | Evidence Type | Location |
|--------|-------------|---------------|----------|
| Extreme noise behavior | Behavior under large stochastic forcing | Diagnostic | `experiments/stress_test.jl` |
| Breakdown regimes | Identification of numerical limits | Diagnostic | `experiments/stress_test.jl` |
| SPD violations under stress | Documented failure under adversarial regimes | Diagnostic | `experiments/stress_test.jl` |

**Interpretation:**  
Failure modes are explicitly documented and are consistent with known numerical
limitations of explicit SDE solvers.

---

## 10. Summary

This manifest establishes that:

- All major claims made by `CovarianceDynamics.jl` are supported by explicit
  validation evidence.
- Structural, dynamical, and numerical aspects are validated independently.
- Limitations and failure regimes are documented transparently.
- Validation is reproducible, auditable, and conservative.

This document serves as the **central index** for validation and is intended to
support technical review, funding evaluation, and future development.

