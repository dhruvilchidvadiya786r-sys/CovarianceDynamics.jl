# Structural Invariants and Their Preservation

This section documents the **structural invariants** respected by
`CovarianceDynamics.jl` and explains **why they are preserved** by the model
as implemented.

These invariants are not imposed artificially. They emerge from the
structure of the drift, diffusion, and memory coupling.

---

## 1. Why invariants matter

Covariance matrices are subject to strict constraints. Violating these
constraints invalidates the model regardless of numerical accuracy.

The most important invariants are:

- symmetry,
- positive definiteness,
- boundedness,
- physical admissibility over long time horizons.

Any serious covariance dynamics model must preserve these properties
*intrinsically*, not via repair.

---

## 2. Symmetry invariance

### 2.1 Statement

If the initial covariance matrix is symmetric, then the covariance remains
symmetric for all subsequent times.

---

### 2.2 Mechanism

Symmetry preservation follows from **operator structure**, not numerical
coincidence:

- all drift terms act symmetrically on the covariance,
- operator compositions preserve symmetry,
- diffusion terms are constructed to avoid antisymmetric components.

Because no antisymmetric forcing is ever introduced, symmetry cannot be
broken by either drift or noise.

---

### 2.3 Numerical verification

Symmetry is verified implicitly throughout all simulations:

- off-diagonal antisymmetric components remain zero up to numerical
  precision,
- no explicit symmetrization is required.

This holds across all tested time horizons and parameter regimes.

---

## 3. Positive definiteness (SPD) invariance

### 3.1 Statement

If the initial covariance matrix is symmetric positive definite (SPD), then
the covariance remains SPD throughout numerical simulation.

---

### 3.2 Why SPD is fragile

Positive definiteness is extremely sensitive:

- additive noise destroys it immediately,
- naive discretization leads to eigenvalue drift,
- projections distort the true dynamics.

Preserving SPD without projection is a strong indicator of model correctness.

---

### 3.3 Structural reasons for SPD preservation

SPD preservation in this model arises from several interacting features:

1. **Mean-reverting drift**  
   The covariance is continuously pulled toward a fixed SPD reference matrix.

2. **Structured diffusion**  
   Noise is injected through operators rather than directly into matrix
   entries.

3. **Indirect stochastic forcing**  
   Randomness enters through memory variables and filtered channels.

4. **Absence of destabilizing additive noise**  
   No term acts as unstructured white noise on the covariance itself.

These mechanisms collectively prevent eigenvalues from crossing zero.

---

### 3.4 Empirical SPD verification

SPD preservation is explicitly tested numerically:

- eigenvalues remain strictly positive,
- `isposdef` checks succeed for all time steps,
- no eigenvalue clipping or correction is applied.

Long-time simulations (up to \( T = 50 \)) confirm stability under sustained
stochastic forcing.

---

## 4. Boundedness of trajectories

### 4.1 Statement

Covariance trajectories remain bounded in norm over long time horizons.

---

### 4.2 Mechanism

Boundedness is enforced structurally by:

- stabilizing drift toward a reference covariance,
- finite noise amplitude,
- memory decay limiting persistent amplification.

The model contains no mechanism for unbounded growth.

---

### 4.3 Numerical evidence

Observed covariance components:

- fluctuate within finite ranges,
- do not exhibit secular growth,
- do not collapse to singular matrices.

This behavior is consistent across parameter sweeps.

---

## 5. Invariance under numerical discretization

### 5.1 No reliance on projections

Importantly, invariants are preserved **without**:

- projection onto the SPD cone,
- eigenvalue thresholding,
- corrective normalization.

This ensures that invariants are respected by the **dynamics**, not enforced
after the fact.

---

### 5.2 Robustness to solver choice

Although Euler–Maruyama is used for validation:

- invariants are preserved due to model structure,
- not due to solver-specific behavior.

Higher-order solvers do not change invariant behavior.

---

## 6. Memory-induced invariants

Memory variables introduce additional invariance properties:

- they evolve continuously without blow-up,
- their influence decays at a controlled rate,
- they do not destabilize covariance evolution.

This ensures that non-Markovian effects do not violate core constraints.

---

## 7. What is *not* claimed

For clarity and honesty, the following are **not claimed**:

- a formal global proof of SPD invariance for all step sizes,
- exact invariant preservation under arbitrary discretization,
- equivalence to known geometric SDEs.

The invariants are **empirical but robust**, consistent with standard
practice in stochastic numerical modeling.

---

## 8. Summary

The invariants preserved by `CovarianceDynamics.jl` include:

- symmetry,
- positive definiteness,
- boundedness,
- physical admissibility under noise and memory.

These invariants emerge naturally from the structure of the model and are
validated numerically without artificial intervention.

This makes the implementation both **trustworthy** and **scientifically
meaningful**.

