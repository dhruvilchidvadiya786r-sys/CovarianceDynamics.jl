# Benchmarks: Performance and Scaling Characteristics

This section documents the **computational performance** of  
`CovarianceDynamics.jl` and analyzes how cost scales with problem size,  
time horizon, and model complexity.

The purpose of these benchmarks is not micro-optimization, but to establish  
that the implementation is **efficient enough to be useful**, **scales  
predictably**, and **does not hide pathological bottlenecks**.

---

## 1. Benchmarking philosophy

Benchmarking in this project follows three guiding principles:

1. **Model-first performance**  
   Performance is measured on the *full stochastic model*, not isolated kernels.

2. **Realistic workloads**  
   Benchmarks reflect actual usage: long SDE trajectories with memory effects.

3. **Interpretability over raw speed**  
   Scaling behavior is prioritized over absolute wall-clock timings.

This aligns with expectations of scientific users and funding agencies.

---

## 2. Benchmark environment

All benchmarks are performed under the following conditions:

- Language: Julia (latest stable release)
- Solver: Euler–Maruyama
- Time step:

      Δt = 1e-3

- Platform: standard laptop / workstation CPU
- No GPU acceleration
- No multi-threading unless explicitly stated

These conditions reflect a **baseline environment**, not a tuned HPC setup.

---

## 3. Cost per time step

### 3.1 What is measured

The dominant cost per time step consists of:

- reshaping the covariance state,
- evaluating drift operators,
- evaluating diffusion operators,
- writing results to memory.

No expensive linear algebra operations (e.g. eigendecomposition or projections)  
are performed per step.

---

### 3.2 Observed behavior

For fixed covariance dimension `n`:

- time per step is approximately constant,
- no progressive slowdown is observed,
- memory usage remains stable.

This indicates absence of hidden allocations or state growth.

---

## 4. Scaling with time horizon

### 4.1 Experiment

Simulations are run with increasing final times:

      T = 1
      T = 10
      T = 50

with fixed time step Δt.

---

### 4.2 Results

- total runtime scales linearly with the number of time steps,
- no superlinear overhead is observed,
- solver performance remains consistent.

This confirms that long-time simulations are feasible.

---

## 5. Scaling with covariance dimension

### 5.1 Theoretical expectation

Let `n` denote the covariance dimension.

The state size scales as:

- covariance matrix: O(n²)
- memory variables: O(n²) or smaller

Hence, the expected per-step computational cost scales as:

      cost_per_step ∝ n²

---

### 5.2 Empirical observation

As dimension increases:

- runtime increases smoothly,
- no sudden performance cliffs appear,
- memory usage grows predictably.

This matches theoretical expectations and confirms the absence of  
dimension-dependent instability.

---

## 6. Memory overhead

### 6.1 Allocation behavior

Benchmarks confirm that:

- drift functions are in-place,
- diffusion functions are in-place,
- no significant per-step allocations occur,
- garbage collection overhead is negligible.

This is critical for long-time SDE simulations.

---

### 6.2 Trajectory storage

The dominant memory cost arises from:

- storing solution trajectories,
- retaining state vectors at each time step.

This cost is fully user-controllable via solver output options  
(e.g. saving frequency or online statistics).

---

## 7. Effect of memory dynamics on performance

### 7.1 Additional cost of memory variables

Memory dynamics introduce:

- additional state variables,
- additional drift computations.

However:

- these operations are linear and local,
- they do not change the asymptotic scaling.

---

### 7.2 Practical impact

In practice:

- memory dynamics add a modest overhead,
- total runtime remains dominated by covariance evolution.

This confirms that non-Markovian effects are computationally affordable.

---

## 8. Comparison with naïve covariance models

Compared to naïve covariance SDE models that:

- perform eigenvalue corrections,
- apply projections at each step,
- enforce positive definiteness post hoc,

`CovarianceDynamics.jl`:

- avoids expensive spectral operations,
- achieves better long-time efficiency,
- scales more smoothly with dimension.

This improvement arises directly from **geometric model design**.

---

## 9. Solver dependence

Benchmarks indicate that:

- higher-order solvers increase per-step cost,
- but reduce the number of required steps for accuracy,
- overall runtime remains comparable.

Solver choice allows users to trade accuracy for speed  
without changing the model structure.

---

## 10. Practical performance envelope

Based on benchmarks, the model is well-suited for:

- exploratory research simulations,
- long-time stochastic studies,
- moderate-dimensional covariance dynamics,
- parameter sweeps and sensitivity analysis.

Very high-dimensional problems may benefit from:

- adaptive solvers,
- reduced trajectory storage,
- future low-rank or structure-exploiting optimizations.

---

## 11. Summary

Benchmark results demonstrate that `CovarianceDynamics.jl`:

- scales linearly with simulation time,
- scales predictably with dimension,
- avoids hidden allocations,
- supports long-time integration,
- remains efficient without sacrificing correctness.

These properties make the package suitable for both **serious research use**  
and **high-quality open-source contribution**.
