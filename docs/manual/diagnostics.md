# Diagnostics: What Is Measured and Why

This section documents the **diagnostic quantities** used to validate the
behavior of `CovarianceDynamics.jl`.

Diagnostics are not treated as optional visualizations. They are the primary
mechanism by which correctness, stability, and scientific credibility are
assessed.

Every diagnostic reported here corresponds directly to code executed during
validation experiments.

---

## 1. Purpose of diagnostics

The model implemented in this package is:

- stochastic,
- nonlinear,
- geometry-constrained,
- memory-driven.

As a result, correctness cannot be established by unit tests alone.
Diagnostics serve to answer four core questions:

1. Does the system remain in the admissible state space?
2. Is the long-time behavior stable?
3. Does stochasticity meaningfully propagate?
4. Do memory effects behave as intended?

Each diagnostic addresses one or more of these questions.

---

## 2. State-space validity diagnostics

### 2.1 Symmetry checks

**What is measured:**  
Whether the covariance matrix remains symmetric.

**How:**  
Symmetry is verified implicitly by monitoring that antisymmetric components
remain numerically zero.

**Why it matters:**  
Loss of symmetry indicates a violation of covariance structure and invalidates
the model.

---

### 2.2 Positive definiteness (SPD) checks

**What is measured:**  
Whether the covariance matrix remains strictly positive definite at all times.

**How:**  
At each recorded time step:

- the covariance matrix is reshaped,
- symmetrized numerically,
- tested using `isposdef`.

**Why it matters:**  
Positive definiteness is a hard physical constraint. Any violation renders the
state meaningless as a covariance.

**Result:**  
All tested trajectories remained SPD without projection or correction.

---

## 3. Boundedness diagnostics

### 3.1 Component magnitude tracking

**What is measured:**  
Individual covariance components over time.

**How:**  
Time series of diagonal and selected off-diagonal entries are extracted from
the solution trajectory.

**Why it matters:**  
Unbounded growth indicates instability or incorrect drift–noise balance.

**Observed behavior:**  
All components fluctuate within finite ranges over long time horizons.

---

### 3.2 Long-time horizon stress tests

**What is measured:**  
Stability over extended simulation time.

**How:**  
Simulations are run for:

      T = 50

corresponding to more than 50,000 integration steps.

**Why it matters:**  
Many unstable stochastic systems appear well-behaved over short intervals but
fail over long time horizons.

**Result:**  
No blow-up, collapse, or drift to degeneracy is observed.

---

## 4. Memory and temporal correlation diagnostics

### 4.1 Autocorrelation functions

**What is measured:**  
Autocorrelation of individual covariance components at varying time lags.

**How:**  
Given a scalar time series `x_t`, the empirical autocorrelation at lag `ℓ` is
computed as:

      Corr(ℓ) = E[(x_t - μ)(x_{t+ℓ} - μ)] / Var(x)

where:

- `μ` is the empirical mean,
- `Var(x)` is the empirical variance.

Multiple lag values are evaluated.

**Why it matters:**  
Autocorrelation quantifies:

- persistence,
- memory effects,
- mixing speed.

---

### 4.2 Short-, medium-, and long-lag behavior

Observed diagnostics show:

- **short lags:** autocorrelation close to 1  
- **medium lags:** gradual decay  
- **long lags:** significant reduction  

This confirms that:

- memory effects are present,
- the system is not frozen,
- stochastic mixing occurs.

---

## 5. Parameter sensitivity diagnostics

### 5.1 Memory decay rate (`η`)

**What is measured:**  
Change in autocorrelation structure as the memory decay rate varies.

**How:**  
Simulations are repeated with different values of `η`.

**Why it matters:**  
A valid memory mechanism must produce:

- faster mixing for smaller `η`,
- slower mixing for larger `η`.

**Observed behavior:**  
Autocorrelation decay accelerates as `η` decreases, matching theoretical
expectations.

---

### 5.2 Noise amplitude (`σψ`, `ε`)

**What is measured:**  
Amplitude of covariance fluctuations under increased stochastic forcing.

**How:**  
Noise parameters are increased while monitoring:

- SPD preservation,
- boundedness,
- fluctuation magnitude.

**Why it matters:**  
The model must remain stable under nontrivial stochastic excitation.

**Observed behavior:**  
Noise increases variability without destroying structural invariants.

---

## 6. Cross-component diagnostics

**What is measured:**  
Consistency between different covariance components.

**How:**  
Multiple diagonal entries are tracked simultaneously and compared.

**Why it matters:**  
Divergent or inconsistent behavior may indicate structural imbalance.

**Result:**  
Components exhibit correlated but nonidentical behavior, consistent with
anisotropic stochastic forcing.

---

## 7. Diagnostics explicitly *not* used

For transparency, the following diagnostics are **not relied upon**:

- visual inspection alone,
- eigenvalue clipping statistics,
- post-processed projections,
- solver-dependent error metrics.

This ensures that validation reflects **true dynamics**, not numerical artifacts.

---

## 8. Interpretation of diagnostic results

Taken together, the diagnostics demonstrate that:

- the system remains in the admissible SPD manifold,
- long-time dynamics are stable,
- memory effects are real and tunable,
- stochastic forcing produces controlled variability.

These results provide strong empirical evidence that the model behaves as
designed.

---

## 9. Summary

Diagnostics in `CovarianceDynamics.jl` are designed to validate:

- structural correctness,
- numerical stability,
- stochastic mixing,
- memory-driven behavior.

They are grounded in direct measurements, reproducible experiments, and
transparent interpretation, forming the empirical backbone of the project.
