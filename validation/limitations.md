# Limitations and Non-Guarantees

This document explicitly documents the **limitations, non-guarantees, and known
failure modes** of `CovarianceDynamics.jl`.

The purpose of this file is to:
- prevent overinterpretation of empirical results,
- clarify the scope of validated behavior, and
- make the numerical and theoretical boundaries of the package explicit.

This document is considered a **core part of validation**, not an afterthought.

---

## 1. Philosophy of Limitations

Scientific software is reliable **not because it never fails**, but because:

- failure modes are understood,
- limits are documented,
- and claims are scoped conservatively.

Accordingly, `CovarianceDynamics.jl` **does not** claim correctness or stability
outside the regimes explicitly validated.

---

## 2. No Global Theoretical Guarantees

### 2.1 No Global Stability Proofs

**Non-Guarantee**  
No global or asymptotic stability theorems are claimed.

**Explanation**
- Stability results are empirical and finite-time.
- Lyapunov-type functionals are used diagnostically, not as proofs.

**Implication**
Users should not assume:
- global convergence,
- asymptotic stationarity,
- or stability under arbitrary parameter choices.

---

### 2.2 No Spectral Gap or Mixing Theorems

**Non-Guarantee**
No rigorous spectral gap, exponential mixing, or ergodicity theorems are claimed.

**Explanation**
- Mixing behavior is assessed empirically via autocorrelation decay.
- Results depend on observation window, noise level, and discretization.

**Implication**
Reported mixing times are **diagnostic estimates**, not mathematical guarantees.

---

## 3. Discretization-Dependent Behavior

### 3.1 Euler–Maruyama Is Not Structure-Preserving

**Limitation**
The default solver (Euler–Maruyama) does **not** preserve invariants exactly.

**Observed Behavior**
- SPD violations can occur under:
  - extreme noise,
  - weak mean reversion,
  - aggressive time steps.

**Evidence**
- `experiments/stress_test.jl`

**Implication**
Users operating in adversarial regimes may require:
- smaller time steps,
- alternative solvers,
- or explicit projection strategies.

---

### 3.2 No Discretization-Independent Guarantees

**Non-Guarantee**
No guarantees are made that properties observed at one time step persist under
arbitrary changes in discretization.

**Implication**
Numerical behavior must be re-validated when:
- increasing `dt`,
- changing solvers,
- altering noise intensity.

---

## 4. Regime-Dependent Validity

### 4.1 Benign vs Adversarial Regimes

**Limitation**
Validated behavior applies to **benign regimes**, characterized by:
- moderate noise,
- reasonable mean reversion,
- sufficiently small time steps.

**Observed Failure Modes**
- Loss of SPD under extreme noise
- Numerical instability under coarse discretization

**Evidence**
- `experiments/stress_test.jl`

---

### 4.2 Solver Performance Is Regime-Dependent

**Limitation**
Higher-order solvers do not universally outperform simpler methods.

**Observed Behavior**
- In some regimes, Euler–Maruyama performs comparably or better.
- Solver choice depends on:
  - noise structure,
  - desired accuracy,
  - computational cost.

**Evidence**
- `experiments/solver_comparison.jl`

---

## 5. Finite-Time Validation Only

### 5.1 No Infinite-Horizon Guarantees

**Limitation**
All validation is performed over **finite time horizons**.

**Implication**
No claims are made about:
- infinite-time behavior,
- asymptotic invariant measures,
- long-term ergodicity beyond tested horizons.

---

### 5.2 Empirical Bounds Depend on Observation Window

**Limitation**
Boundedness and stability diagnostics depend on:
- simulation duration,
- random seed,
- noise realization.

**Implication**
Bounds may shift if:
- time horizons are extended,
- parameters are modified,
- noise structure changes.

---

## 6. Model Scope Limitations

### 6.1 Specificity to Covariance Dynamics

**Limitation**
The package is designed specifically for covariance-matrix-valued dynamics.

**Non-Guarantee**
It does not claim applicability to:
- arbitrary matrix-valued SDEs,
- non-SPD manifolds,
- unrelated stochastic systems.

---

### 6.2 Memory Model Assumptions

**Limitation**
The memory structure assumes:
- finite-dimensional Markovian lifting,
- specific decay forms.

**Implication**
Other memory kernels or nonlocal effects may require:
- alternative formulations,
- re-validation.

---

## 7. Numerical and Implementation Scope

### 7.1 Dependency Behavior

**Limitation**
Behavior depends on:
- Julia version,
- `DifferentialEquations.jl` implementation,
- solver defaults.

**Implication**
Exact numerical results may differ across:
- versions,
- platforms,
- hardware.

Reproducibility is guaranteed only under fixed environments.

---

## 8. Summary of Non-Guarantees

`CovarianceDynamics.jl` explicitly does **not** guarantee:

- global or asymptotic stability
- discretization-independent invariance
- exact invariant preservation under EM
- theoretical mixing rates
- universal solver optimality
- correctness outside validated regimes

These non-guarantees are **intentional** and documented to ensure correct usage
and interpretation.

---

## 9. Role of This Document

This limitations document exists to ensure that:

- users understand the scope of validity,
- reviewers can assess risk accurately,
- future contributors know where theory ends and diagnostics begin.

Together with `guarantees.md`, this file establishes a **clear, honest contract**
between the package and its users.

