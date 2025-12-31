# Numerical Safety Callbacks (`callbacks.jl`)

## Purpose

The `callbacks.jl` file defines **optional numerical safeguards**
used to protect simulations from discretization-induced violations
of structural invariants.

These callbacks are **not part of the mathematical model**.
They exist solely to ensure numerical robustness.

---

## Why callbacks are necessary

The continuous-time model guarantees:
- symmetry and positive definiteness of the covariance
- nonnegativity of auxiliary variables

However, time discretization can break these invariants due to:
- finite step sizes
- solver error accumulation
- stiff interactions

Callbacks intervene **only when violations occur**.

---

## SPD Invariance Enforcement

### Detection

The callback checks for:
- loss of symmetry
- non-positive eigenvalues

This minimizes unnecessary intervention.

---

### Enforcement

When triggered:
- the covariance matrix is projected onto the SPD cone
- auxiliary variables are clamped to nonnegative values

Projection uses eigenvalue clipping, which is:
- stable
- deterministic
- minimal

---

## Auxiliary Variable Enforcement

Flux and memory variables are required to remain nonnegative.

When violations occur:
- values are clamped to zero
- no further modification is made

This prevents unphysical behavior.

---

## Combined Safety Callbacks

The `safety_callbacks()` function returns a `CallbackSet` combining:
- SPD enforcement
- auxiliary nonnegativity enforcement

This is provided as a **convenience default**, not a requirement.

Users may:
- disable callbacks entirely
- use only selected callbacks
- implement custom safeguards

---

## Diagnostics

The function `violates_invariants` allows:
- post-processing checks
- debugging
- testing theoretical vs numerical behavior

This function does **not** modify the state.

---

## What does NOT belong in this file

The following are intentionally excluded:

- mathematical model definitions
- drift or diffusion terms
- solver construction
- diagnostics requiring integration

This strict separation avoids conceptual confusion.

---



