# Validation & Verification

This folder documents the **validation strategy, evidence, and scope** for
`CovarianceDynamics.jl`.

The purpose of validation here is **not** to introduce new algorithms or
duplicate implementation logic, but to provide a **clear, auditable, and
scientifically honest record** of how the correctness, stability, and behavior
of the package have been evaluated.

This validation layer is intentionally **separate** from both the core source
code and the unit test suite.

---

## 1. Philosophy of Validation

Validation in this project follows three core principles:

1. **Separation of concerns**
2. **Empirical honesty**
3. **Reproducibility over spectacle**

In particular:

- **Unit tests** (`test/`) verify *structural correctness* and *reproducibility*
  and are intended to run in continuous integration (CI).
- **Validation scripts** (documented here) provide *scientific diagnostics* and
  *behavioral evidence* that go beyond what unit tests can or should assert.
- **No theoretical guarantees are claimed unless proven elsewhere**; all
  statements here are explicitly empirical.

This approach mirrors best practices in the SciML ecosystem and modern research
software engineering.

---

## 2. What This Folder Contains (and Does Not Contain)

### This folder **contains**
- A structured description of all validation evidence
- Clear statements of what has been verified empirically
- Explicit documentation of known limitations
- Reproducibility instructions for all validation results

### This folder **does NOT contain**
- New numerical solvers
- New model definitions
- Unit tests or CI logic
- Hidden assumptions or undocumented behavior
- Plots required for correctness claims

All validation scripts referenced here already exist elsewhere in the repository
(e.g. `test/`, `experiments/`, or `examples/`).

---

## 3. Categories of Validation

Validation is organized into the following conceptual layers.

### 3.1 Structural Correctness

Structural validation answers the question:

> *Is the mathematical structure of the model implemented correctly?*

This includes:
- Preservation of symmetry
- Preservation of positive definiteness (SPD) in appropriate regimes
- Correct dimensionality of the lifted Markovian state
- Proper coupling of auxiliary memory variables

Evidence for these properties is provided by deterministic unit tests.

---

### 3.2 Stability and Boundedness

Stability validation answers the question:

> *Does the system remain numerically well-behaved over time in realistic regimes?*

This includes:
- Empirical boundedness of Lyapunov-type functionals
- Absence of numerical explosion or drift
- Long-time behavior under moderate noise

These checks are **empirical diagnostics**, not proofs, and are evaluated under
clearly specified regimes.

---

### 3.3 Memory and Dynamical Behavior

Dynamical validation answers the question:

> *Does the model actually exhibit the intended non-Markovian behavior?*

This includes:
- Autocorrelation decay analysis
- Empirical mixing-time estimation
- Dependence of dynamics on the memory decay parameter
- Verification that auxiliary memory variables influence the evolution

These diagnostics demonstrate that memory effects are *active and meaningful*,
not cosmetic.

---

### 3.4 Solver Behavior and Numerical Regimes

Solver validation answers the question:

> *How does the model behave under different numerical solvers and step sizes?*

This includes:
- Comparison of Euler–Maruyama with higher-order SDE solvers
- Identification of regimes where simple solvers are sufficient
- Explicit documentation of regimes where numerical breakdown can occur

No solver is claimed to be universally superior; solver choice is shown to be
**regime-dependent**.

---

### 3.5 Stress and Failure Modes

A key part of validation is answering:

> *Where does the model fail, and why?*

Stress diagnostics explore:
- Extreme noise levels
- Weak mean-reversion regimes
- Aggressive discretization

Observed failures (e.g. loss of SPD under extreme conditions) are **documented
explicitly**, not hidden, and are consistent with known numerical limitations of
the underlying solvers.

---

## 4. Guarantees vs. Non-Guarantees

This project carefully distinguishes between:

### Empirically validated properties
- Structural invariants in benign regimes
- Finite-time boundedness
- Reproducibility under fixed RNG seeds
- Correct Markovian lifting of non-Markovian dynamics

### Properties **not** claimed
- Global or asymptotic stability proofs
- Exact invariant preservation under arbitrary discretization
- Rigorous spectral gap or mixing rate theorems
- Universally stable behavior under extreme noise

All guarantees and limitations are documented explicitly in separate files.

---

## 5. Reproducibility

All validation results are reproducible using the provided scripts and a fixed
project environment.

Reproduction involves:
1. Activating the project environment
2. Running the official unit test suite
3. Executing selected validation scripts

No external data or undocumented configuration is required.

---

## 6. Intended Audience

This validation documentation is written for:

- **SciML maintainers**, evaluating ecosystem contributions
- **NumFOCUS reviewers**, assessing technical risk and maturity
- **Researchers and PhD students**, evaluating correctness and scope
- **Future contributors**, understanding what is already validated

The goal is clarity, not persuasion.

---

## 7. Summary

In summary, this validation layer ensures that:

- Claims made by `CovarianceDynamics.jl` are **supported by evidence**
- Limitations are **explicit and documented**
- Numerical behavior is **understood, not assumed**
- The repository meets the standards of **serious scientific software**

This folder completes the transition of the project from an implementation to a
**validated research-grade software artifact**.

