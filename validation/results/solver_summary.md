# Solver Behavior Summary

This document summarizes the **numerical solver validation evidence** for
`CovarianceDynamics.jl`.

The goal of this summary is not to promote a particular solver, but to document
**how solver choice, discretization, and noise regime affect numerical behavior**.

All observations reported here are empirical.

---

## 1. Scope of Solver Validation

Solver validation addresses the following questions:

1. How does numerical accuracy depend on solver choice?
2. How sensitive are results to time-step size?
3. Are higher-order solvers uniformly superior?
4. In which regimes does numerical breakdown occur?

These questions are addressed through controlled solver comparison experiments.

---

## 2. Solvers Evaluated

The following solvers from `DifferentialEquations.jl` were evaluated:

- **Euler–Maruyama (EM)**  
  - Explicit, first-order strong scheme
  - Computationally efficient
  - Widely used for exploratory diagnostics

- **Higher-order strong solvers** (e.g. SOSRI)  
  - Higher strong order under appropriate noise conditions
  - Increased computational cost

No solver-specific modifications were introduced.

---

## 3. Reference Solution Strategy

### Method

- A fine-step Euler–Maruyama solution was used as a **reference trajectory**.
- Coarser-step solutions were compared against this reference using
  trajectory-based error metrics.

### Rationale

- Avoids reliance on unavailable closed-form solutions
- Provides a consistent baseline for solver comparison
- Emphasizes practical numerical accuracy

---

## 4. Observed Accuracy Behavior

### Evidence

- `experiments/solver_comparison.jl`

### Observations

- Solver accuracy depends strongly on:
  - noise intensity,
  - time-step size,
  - memory parameter regime.
- Higher-order solvers do not uniformly outperform EM.
- In some regimes, EM provides comparable or superior performance at lower cost.

### Interpretation

Solver choice is **regime-dependent** and must be guided by the intended use
case rather than solver order alone.

---

## 5. Stability Considerations

### Observations

- All solvers tested are stable in benign regimes with sufficiently small
  time steps.
- Numerical instability and invariant violation occur primarily due to:
  - large time steps,
  - extreme noise levels,
  - weak mean reversion.

### Interpretation

Instability is attributed to **numerical discretization limits**, not to
implementation errors.

---

## 6. Invariant Preservation

### Observations

- No solver is guaranteed to preserve SPD exactly under discretization.
- In validated regimes:
  - invariants are preserved empirically,
  - minimum eigenvalues remain safely bounded.

### Interpretation

Invariant preservation arises from the **structure of the continuous model**,
not from solver-enforced constraints.

---

## 7. Performance and Practical Guidance

### Observations

- Euler–Maruyama is sufficient for:
  - exploratory analysis,
  - validation diagnostics,
  - benign parameter regimes.
- Higher-order solvers may be preferable for:
  - higher accuracy requirements,
  - finer resolution of stochastic effects.

### Guidance

Users are encouraged to:
- perform solver sensitivity checks,
- reduce time step when increasing noise,
- avoid assuming solver superiority without regime analysis.

---

## 8. Non-Claims and Boundaries

Solver validation **does not claim**:

- solver-independent accuracy,
- universal invariant preservation,
- stability under arbitrary discretization,
- optimality of any solver across all regimes.

These limitations are intentional and documented.

---

## 9. Summary

Solver validation demonstrates that:

- numerical behavior is predictable and explainable,
- solver choice is regime-dependent,
- observed instabilities align with known numerical limitations,
- no hidden solver-specific assumptions are made.

This conservative treatment of solver behavior supports the use of
`CovarianceDynamics.jl` as a **reliable research tool**, while encouraging
responsible numerical practice.
