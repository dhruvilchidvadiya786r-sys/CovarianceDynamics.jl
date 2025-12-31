# Limitations, Assumptions, and Scope Boundaries

This section documents the **known limitations**, **explicit assumptions**,
and **intended scope boundaries** of `CovarianceDynamics.jl`.

These limitations are not failures. They are the result of deliberate design
choices and define the domain in which the model is scientifically and
numerically reliable.

---

## 1. Scope of the model

`CovarianceDynamics.jl` is designed to model **autonomous stochastic covariance
dynamics with memory**, not to solve all covariance-related problems.

The package is intended for:

- research-grade simulation,
- exploratory modeling,
- long-time stochastic analysis,
- mechanistic, interpretable dynamics.

It is **not** intended as a drop-in replacement for classical filtering or
estimation algorithms.

---

## 2. Absence of formal invariant proofs

### 2.1 What is not proven

The package does **not** provide:

- a formal global proof of positive definiteness preservation,
- step-size-independent invariant guarantees,
- closed-form invariant measures.

---

### 2.2 Why this is acceptable

For stochastic geometric systems:

- rigorous global proofs are rare,
- numerical validation is standard practice,
- empirical invariance over long horizons is meaningful evidence.

The model passes **strong numerical stress tests** without artificial repair,
which would not be possible if invariance were accidental.

---

## 3. Dependence on discretization parameters

### 3.1 Time step sensitivity

As with all explicit SDE solvers:

- excessively large time steps can destabilize the system,
- stability depends on resolving the fastest dynamics.

The documentation reports results for:

      Δt = 1e-3

which is conservative.

---

### 3.2 Solver choice

Although solver-agnostic in principle:

- higher-order solvers may be required for extreme regimes,
- adaptive stepping may be beneficial in high dimensions.

The package does not attempt to enforce solver choice.

---

## 4. Dimensional scaling limitations

### 4.1 Quadratic state growth

The covariance matrix contributes:

      n²

state variables.

As a result:

- memory and computation scale quadratically with dimension,
- very high-dimensional problems may become expensive.

This is an inherent property of covariance modeling, not an implementation
defect.

---

### 4.2 Practical implications

The current implementation is best suited for:

- small to moderate dimensions,
- detailed analysis rather than massive scale.

Future optimizations may alleviate this but cannot remove it entirely.

---

## 5. Restricted class of memory kernels

### 5.1 Current implementation

The package currently implements:

- exponential memory kernels.

This choice ensures:

- numerical stability,
- finite memory state,
- Markovian lifting.

---

### 5.2 What is not included

The following are **not currently supported**:

- power-law memory kernels,
- fractional Brownian memory,
- arbitrary nonparametric kernels.

These extensions are possible but nontrivial.

---

## 6. Hypoellipticity and mixing speed

### 6.1 Slow mixing

Due to structured noise injection:

- some components mix slowly,
- autocorrelation decay can be long-tailed.

This is a **feature**, not a bug, but may be undesirable for some applications.

---

### 6.2 Implications

Users seeking:

- rapid equilibration,
- strong isotropic noise,

may need to adjust parameters or consider alternative models.

---

## 7. No observational coupling

The model is **autonomous**:

- it does not include observation updates,
- it is not a filtering algorithm,
- it does not incorporate data assimilation.

Users requiring observation-driven covariance updates should combine this
model with external estimation frameworks.

---

## 8. Interpretation limitations

### 8.1 Model-dependent meaning

Covariance trajectories reflect:

- model structure,
- parameter choices,
- memory assumptions.

They should not be interpreted as empirical estimates without contextual
justification.

---

### 8.2 Parameter calibration

The package does not provide automated parameter estimation or calibration.

Users are responsible for:

- selecting meaningful parameters,
- validating assumptions in their domain.

---

## 9. Numerical reproducibility constraints

While reproducible under fixed conditions:

- stochastic trajectories vary across runs,
- exact replication requires fixed seeds and solvers.

This is intrinsic to stochastic simulation.

---

## 10. Summary of limitations

The key limitations of `CovarianceDynamics.jl` are:

- lack of formal invariant proofs,
- quadratic scaling with dimension,
- reliance on explicit discretization,
- limited memory kernel classes,
- autonomous (non-filtering) formulation.

These limitations are transparent, well-understood, and consistent with the
intended scope of the project.

---

## 11. Why these limitations strengthen the project

By stating these limitations explicitly, the project:

- avoids overstated claims,
- builds reviewer trust,
- clarifies appropriate usage,
- provides a solid foundation for future work.

This transparency is essential for serious scientific open-source software.
