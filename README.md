# CovarianceDynamics.jl

**A Julia package for stochastic covariance dynamics on the symmetric positive-definite (SPD) manifold, with optional non-Markovian memory via finite-dimensional Markovian lifts.**

[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Julia](https://img.shields.io/badge/Julia-1.9+-9558B2?logo=julia)](https://julialang.org)
[![SciML Compatible](https://img.shields.io/badge/SciML-Compatible-blue)](https://sciml.ai)

## Overview

`CovarianceDynamics.jl` provides a mathematically rigorous implementation of **stochastic differential equations (SDEs)** for covariance matrices evolving on the manifold of symmetric positive-definite (SPD) matrices. It supports:

- Exact preservation of symmetry and positive definiteness
- Incorporation of **long-memory (non-Markovian) effects** through a finite-dimensional Markovian lift
- Full integration with the **SciML ecosystem** (`DifferentialEquations.jl`, solvers, callbacks, etc.)
- Built-in diagnostics for Lyapunov stability, ergodicity, mixing rates, and invariant measures
- Long-time ergodic simulations with controllable memory persistence

This enables advanced analysis of covariance flows in applications such as:
- Financial time series with persistent volatility clustering
- Turbulence modeling and fluid dynamics
- Kalman filtering with colored noise
- Machine learning dynamics (e.g., natural gradient flows with history dependence)

## Why This Package Exists

Standard stochastic models for covariance evolution often fail because:
- The SPD "manifold" is **not a vector space** — naïve Euler schemes destroy positive definiteness or symmetry
- Most models are purely **Markovian**, unable to capture long-range temporal correlations
- Existing geometric SDE integrations on SPD matrices typically lack memory extensions

`CovarianceDynamics.jl` solves both problems simultaneously:
1. Uses **geometric integration** to respect SPD manifold structure
2. Employs a **controlled Markovian embedding** to introduce memory without losing analytic tractability

All design choices are backed by **numerical validation** of key invariants and long-time behavior.

## Key Features

- **SPD-invariant dynamics**: Covariance remains symmetric and positive definite indefinitely
- **Memory via Markovian lift**: Finite auxiliary variables introduce tunable non-Markovian effects
- **SciML integration**: Define problems as standard `SDEProblem`, use any solver from `DifferentialEquations.jl`
- **Diagnostics suite**: Lyapunov exponents, autocorrelation functions, trace/variance monitoring, invariant measure sampling
- **Extensible architecture**: Easy to add custom drift/diffusion terms or memory kernels
- **Reproducible examples**: From basic simulations to stress tests and ergodicity demonstrations

## Installation

The package is not yet registered. Install directly from GitHub:

```julia
using Pkg
Pkg.add(url="https://github.com/dhruvilchidvadiya786r-sys/CovarianceDynamics.jl")
```

Dependencies are managed automatically (primarily `DifferentialEquations.jl`, `LinearAlgebra`, `Statistics`).

## Quick Start

```julia
using CovarianceDynamics
using DifferentialEquations

# Define a simple covariance SDE with memory
prob = covariance_sde_problem(dimension=3, memory_strength=0.5)

# Solve over long time horizon
sol = solve(prob, SOSRI(), dt=0.01, saveat=1.0, tstops=0:10:10000)

# Extract covariance trajectory
cov_traj = [sol.u[i].Σ for i in eachindex(sol.u)]

# Diagnostic: check SPD invariance
all(issymmetric(C) && isposdef(C) for C in cov_traj)  # → true
```

See the `examples/` directory for complete scripts:
- `basic_simulation.jl`
- `memory_effects.jl`
- `lyapunov_verification.jl`
- `ergodicity_demo.jl`
- `stress_test.jl`

## Theoretical Guarantees (Numerically Validated)

| Property                  | Status                  | Evidence Location          |
|---------------------------|-------------------------|----------------------------|
| SPD invariance            | Always preserved        | Tests + experiments        |
| Symmetry preservation     | Exact                   | Geometric formulation      |
| No explosion/collapse     | Long-time bounded       | 10⁴–10⁵ time unit runs     |
| Ergodicity (Markovian)    | Convergent averages     | Diagnostics                |
| Controllable memory decay | Tunable mixing rates    | Parameter sweeps           |
| Invariant regime existence| Time averages converge  | Ergodicity demos           |

**Note**: These are **numerical observations**, not formal proofs.

## Documentation

Detailed documentation (including motivation, mathematical derivations, model equations, geometric details, numerical methods, limitations, and reproducibility) is available in the `/docs/` directory.

Key sections:
- **Motivation & Problem Gap**
- **Mathematical Background & Theory**
- **Exact Model Equations**
- **Geometry and Invariants**
- **Numerical Implementation**
- **Diagnostics and Validation**
- **Experiments and Reproducibility**
- **Limitations and Future Roadmap**

The package emphasizes **transparency, correctness, and reproducibility** over performance optimization at this stage.

## Status & Roadmap

- **Current status**: Active development (initial release December 2025)
- **Focus**: Correctness, clarity, numerical validation, extensibility
- **Upcoming**:
  - Formal registration in Julia General
  - More diagnostic tools (spectral analysis, Lyapunov spectrum estimation)
  - Extension to structured covariances (e.g., block-diagonal)
  - Performance-optimized solvers

Contributions, issues, and feedback are highly encouraged!

## License

MIT License — see `LICENSE` for details.

## Citation

If you use this package in research, please cite the repository (see `CITATION.cff` when available).

---

**CovarianceDynamics.jl** — Stochastic covariance flows, geometrically correct, with memory.
