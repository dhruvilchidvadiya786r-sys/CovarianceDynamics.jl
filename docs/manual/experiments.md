# Numerical Experiments and Empirical Validation

This section documents the **numerical experiments** conducted to validate
the behavior of `CovarianceDynamics.jl`.

The goal of these experiments is not to demonstrate aesthetic simulations,
but to provide **empirical evidence** that the model:

- preserves structural invariants,
- remains stable over long time horizons,
- exhibits meaningful stochastic and memory-driven behavior,
- responds predictably to parameter variation.

All experiments reported here are **fully reproducible** using the public
codebase.

---

## 1. Experimental philosophy

The experiments are designed around three principles:

1. **Stress over polish**  
   Long runs and simple solvers are preferred to expose instability.

2. **Minimal intervention**  
   No projections, no clipping, no corrective steps.

3. **Direct measurement**  
   All conclusions are based on explicitly computed diagnostics.

This philosophy ensures that observed behavior reflects the **true model
dynamics**, not numerical artifacts.

---

## 2. Baseline experiment: short-time validation

### 2.1 Objective

To verify that the model behaves correctly over short time horizons and
produces sensible stochastic trajectories.

---

### 2.2 Setup

- Dimension: \( n = 2 \)
- Initial covariance: identity matrix
- Time horizon: \( T = 1 \)
- Time step: \( \Delta t = 10^{-3} \)
- Solver: Euler–Maruyama

Memory and noise parameters are chosen to be moderate.

---

### 2.3 Observations

- covariance remains symmetric and SPD,
- stochastic fluctuations are visible,
- no numerical instability is observed.

This experiment serves as a basic sanity check before long-time runs.

---

## 3. Long-time stability experiment

### 3.1 Objective

To test whether the model remains stable over extended simulation time
without numerical repair mechanisms.

---

### 3.2 Setup

- Dimension: \( n = 2 \)
- Time horizon: \( T = 50 \)
- Number of steps: 50,000+
- Solver: Euler–Maruyama
- No projection or correction

---

### 3.3 Observations

- covariance components remain bounded,
- no eigenvalues approach zero or infinity,
- stochastic variability persists without blow-up.

This experiment demonstrates **long-time numerical stability**.

---

## 4. Positive definiteness stress test

### 4.1 Objective

To verify that positive definiteness is preserved under sustained stochastic
forcing.

---

### 4.2 Setup

During the long-time simulation:

- the covariance matrix is checked at every time step,
- `isposdef` is applied to the symmetric form.

---

### 4.3 Results

- all covariance matrices remain strictly SPD,
- no correction or projection is applied,
- violations are never observed.

This provides strong empirical evidence of geometric consistency.

---

## 5. Autocorrelation and mixing experiment

### 5.1 Objective

To quantify temporal dependence and stochastic mixing.

---

### 5.2 Setup

- extract a single diagonal covariance component,
- compute empirical autocorrelation at multiple lags,
- evaluate decay behavior.

Lags range from short (10 steps) to long (2000 steps).

---

### 5.3 Observations

- autocorrelation is close to 1 at short lags,
- gradual decay occurs at intermediate lags,
- significant decay is observed at long lags.

This confirms:
- memory effects are present,
- the system is not frozen,
- stochastic mixing occurs.

---

## 6. Memory decay parameter sweep

### 6.1 Objective

To test whether the memory parameter (`η`) behaves as intended.

---

### 6.2 Setup

Multiple simulations are run with varying `η`:

- larger `η`: slower memory decay,
- smaller `η`: faster relaxation.

All other parameters are held fixed.

---

### 6.3 Observations

- decreasing `η` accelerates autocorrelation decay,
- increasing `η` leads to longer temporal persistence.

This confirms that memory effects are **tunable and interpretable**.

---

## 7. Noise amplitude sensitivity experiment

### 7.1 Objective

To test robustness under stronger stochastic forcing.

---

### 7.2 Setup

Noise parameters (`σψ`, `ε`) are increased while monitoring:

- SPD preservation,
- boundedness,
- variability amplitude.

---

### 7.3 Observations

- covariance fluctuations increase in magnitude,
- invariants remain preserved,
- no instability or blow-up occurs.

This demonstrates robustness to noise.

---

## 8. Cross-component consistency experiment

### 8.1 Objective

To verify consistent behavior across different covariance components.

---

### 8.2 Setup

- multiple diagonal entries are tracked,
- trajectories are compared statistically.

---

### 8.3 Observations

- components exhibit correlated but distinct behavior,
- no component dominates or collapses.

This is consistent with structured, anisotropic stochastic forcing.

---

## 9. Negative results and failure modes

For transparency, the following observations are noted:

- excessively large time steps eventually destabilize the system,
- extreme noise amplitudes require smaller `Δt`,
- very high dimensions may require adaptive solvers.

These limitations are expected and documented explicitly.

---

## 10. Reproducibility

All experiments are reproducible by:

- fixing the random seed,
- using the same solver and time step,
- using the documented parameters.

Scripts corresponding to these experiments are included in the repository.

---

## 11. Summary of experimental evidence

The experiments collectively demonstrate that:

- the model is numerically stable over long time horizons,
- structural invariants are preserved without repair,
- memory effects behave predictably,
- stochastic forcing produces controlled variability.

These results provide strong empirical validation of the model implemented
in `CovarianceDynamics.jl`.

