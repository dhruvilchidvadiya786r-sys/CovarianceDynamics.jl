# Type System (`types.jl`)

## Purpose

The `types.jl` file defines the **type-level foundation** of
**CovarianceDynamics.jl**.

It introduces all abstract interfaces and concrete data structures
required to describe covariance dynamics with memory, without
implementing any dynamics or numerical logic.

This file establishes the **identity and structure** of the model.

---

## Why this file exists

In scientific software, poor type design leads to:
- parameter duplication
- implicit assumptions
- unstable numerical behavior
- unmaintainable code

`types.jl` avoids these problems by enforcing:
- immutability
- explicit structure
- type stability
- clear separation of concerns

---

## What is defined here

### Abstract Interfaces
- `AbstractCovarianceModel`
- `AbstractMemoryKernel`
- `AbstractLaplacianOperator`

These interfaces allow the model to be extended with:
- alternative memory kernels
- different interaction operators
- future control or learning mechanisms

---

### Memory Kernel Types

Currently implemented:
- `ExponentialMemory`

This kernel admits an **exact finite-dimensional Markovian lift**,
which is critical for ergodicity analysis and long-time simulation.

---

### Interaction Operator Types

Currently implemented:
- `CorrelationLaplacian`

This operator induces structured interactions by transforming the
covariance matrix into a correlation-based graph Laplacian.

---

### Parameter Container

The `CovMemoryParams` struct is the **single source of truth** for
all model parameters. It is:

- immutable
- type-stable
- passed unchanged throughout the system
- compatible with SciML solvers

Parameter validation is performed at construction time to prevent
silent errors during simulation.

---

## What must NOT go in this file

The following are intentionally excluded:

- drift equations
- stochastic diffusion terms
- numerical solvers
- callbacks or projections
- diagnostics

Those belong in later layers of the architecture.

---




