# Guarantees

This document enumerates the **guarantees provided by `CovarianceDynamics.jl`**,
together with their **scope, basis, and limitations**.

All guarantees listed here are:
- supported by explicit validation evidence, and
- restricted to clearly defined regimes.

No unstated or implicit guarantees are claimed.

---

## 1. Nature of Guarantees

The guarantees in this project are of two types:

1. **Structural guarantees**  
   Properties that follow from the formulation and are verified deterministically
   by unit tests.

2. **Empirical guarantees**  
   Properties observed consistently under controlled numerical experiments,
   without claiming theoretical proofs.

Unless explicitly stated otherwise, guarantees are **empirical**.

---

## 2. Structural Guarantees

Structural guarantees concern properties that must hold for correctness of the
model implementation.

### 2.1 Symmetry Preservation

**Guarantee**  
Covariance matrices remain symmetric throughout the evolution.

**Basis**  
- Symmetry is enforced by construction of the state representation.
- Verified by deterministic unit tests.

**Evidence**
- `test/test_spd_invariance.jl`

**Scope**
- All tested regimes.
- Independent of solver choice.

---

### 2.2 Positive Definiteness (SPD) in Benign Regimes

**Guarantee**  
In benign regimes (moderate noise, sufficiently small time step),
covariance matrices remain strictly positive definite.

**Basis**
- Structural formulation respects the SPD cone.
- Verified empirically in unit tests and diagnostics.

**Evidence**
- `test/test_spd_invariance.jl`
- `experiments/projection_vs_no_projection.jl`
- `experiments/long_time_run.jl`

**Scope**
- Small to moderate noise.
- Reasonable discretization (`dt` sufficiently small).
- Explicit solvers such as Euler–Maruyama.

---

### 2.3 Correct Markovian Lifting

**Guarantee**  
The non-Markovian covariance dynamics are correctly lifted to a finite-dimensional
Markovian system via auxiliary state variables.

**Basis**
- Explicit augmentation of the state space.
- Verified by unit tests checking state dimension and coupling behavior.

**Evidence**
- `test/test_markov_lift.jl`

**Scope**
- All tested parameter regimes.
- Independent of solver choice.

---

## 3. Stability and Boundedness Guarantees (Empirical)

### 3.1 Finite-Time Boundedness

**Guarantee**  
A natural quadratic Lyapunov-type functional remains finite and bounded over
finite time horizons in benign regimes.

**Basis**
- Empirical evaluation under controlled stochastic forcing.
- No claim of monotonic decay.

**Evidence**
- `test/test_lyapunov.jl`
- `experiments/long_time_run.jl`

**Scope**
- Finite simulation horizons.
- Moderate noise levels.
- Explicit time discretization.

---

### 3.2 Absence of Numerical Explosion

**Guarantee**  
No numerical blow-up or divergence is observed in validated regimes.

**Basis**
- Long-time diagnostics.
- Stress-tested against increased noise and weaker mean reversion.

**Evidence**
- `experiments/long_time_run.jl`
- `experiments/stress_test.jl`

**Scope**
- Explicitly excludes adversarial regimes with extreme noise.

---

## 4. Reproducibility Guarantees

### 4.1 Deterministic Reproducibility

**Guarantee**  
Simulations are deterministic under fixed random number generator (RNG) seeds.

**Basis**
- Explicit seeding of RNG.
- No uncontrolled randomness.

**Evidence**
- `test/test_reproducibility.jl`

**Scope**
- Same Julia version and dependency versions.
- Identical solver configuration.

---

### 4.2 Stochastic Sensitivity

**Guarantee**  
Different RNG seeds produce statistically different trajectories.

**Basis**
- Explicit reproducibility tests.

**Evidence**
- `test/test_reproducibility.jl`

**Scope**
- All stochastic simulations.

---

## 5. Memory and Dynamical Behavior Guarantees (Empirical)

### 5.1 Active Memory Effects

**Guarantee**  
Auxiliary memory variables influence the observed covariance dynamics.

**Basis**
- Empirical diagnostics demonstrating nontrivial ψ → I coupling.
- Observable changes in temporal correlations.

**Evidence**
- `test/test_markov_lift.jl`
- `experiments/mixing_rate_estimation_advanced.jl`

**Scope**
- Finite-time simulations.
- Parameter regimes with nonzero memory strength.

---

### 5.2 Finite-Time Mixing Behavior

**Guarantee**  
Temporal correlations decay over time, with decay rates dependent on the memory
decay parameter.

**Basis**
- Empirical autocorrelation analysis.
- Threshold-based mixing diagnostics.

**Evidence**
- `experiments/mixing_rate_estimation.jl`
- `experiments/mixing_rate_estimation_advanced.jl`

**Scope**
- Finite observation windows.
- No claim of asymptotic or exponential mixing rates.

---

## 6. Solver-Dependent Guarantees

### 6.1 Regime-Dependent Solver Accuracy

**Guarantee**  
Solver accuracy depends on the noise regime and discretization scale.

**Basis**
- Direct solver comparisons.
- No universal solver is claimed optimal.

**Evidence**
- `experiments/solver_comparison.jl`

**Scope**
- Explicit solvers in `DifferentialEquations.jl`.
- Strong-error comparisons only.

---

## 7. Summary of Guarantees

The guarantees provided by `CovarianceDynamics.jl` are:

- **Precise** — each claim is scoped and justified
- **Empirical where appropriate** — no unsupported theory claims
- **Reproducible** — supported by deterministic scripts
- **Conservative** — limitations are explicitly documented elsewhere

Together, these guarantees establish `CovarianceDynamics.jl` as a **validated,
research-grade scientific software package**, suitable for ecosystem integration
and further development.

For documented limitations and non-guarantees, see `limitations.md`.

