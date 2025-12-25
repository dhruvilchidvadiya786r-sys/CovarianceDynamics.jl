# Model Definition and Code Mapping

This section defines the **exact stochastic model implemented in CovarianceDynamics.jl** and explains how each mathematical component is realized in code.  

The purpose of this section is **not** to introduce new theory, but to make the implementation **fully transparent**: every state variable, operator, and parameter appearing in the code is motivated and accounted for.

## 1. Overview of the Modeled System

The package implements a **Markovian lifted stochastic system** whose primary objective is to evolve a covariance matrix while:

- preserving symmetry and positive definiteness  
- incorporating memory effects  
- remaining compatible with standard SDE solvers  

The full state is a finite-dimensional vector encoding:

1. the covariance matrix  
2. auxiliary memory variables  

## 2. State Representation

### 2.1 Mathematical State

At the conceptual level, the state at time $t$ is written as

$$
X_t = (C_t, M_t),
$$

where:

- $C_t \in \mathcal{S}_{++}^n$ is the covariance matrix  
- $M_t$ denotes memory-related auxiliary variables  

The system is Markovian in the extended state $X_t$.

### 2.2 Flattened Numerical State

For numerical integration, the state is represented as a **flat real vector**:

- the covariance matrix $C_t$ is flattened into $n^2$ entries  
- memory variables are appended to this vector  

In the current implementation:

- the first $n^2$ entries correspond to the covariance matrix  
- the remaining entries encode memory state  

This representation is required by SciML solvers.

## 3. Parameterization

The model is fully specified by a parameter object of type `CovMemoryParams`, which includes:

- `n` : dimension of the covariance matrix  
- `λ` : mean-reversion strength  
- `C̄` : reference covariance matrix  
- `β` : coupling strength between covariance and operators  
- `σψ` : noise strength acting through memory  
- `ε` : diffusion scaling parameter  
- `U` : structural matrix defining noise geometry  
- `η` : memory relaxation rate  

All parameters are immutable during simulation and are passed explicitly to the drift and diffusion functions.

## 4. Drift Dynamics

### 4.1 Conceptual Structure

The drift of the lifted system combines three effects:

1. **Mean reversion** — The covariance is attracted toward a reference matrix $\bar{C}$.  
2. **Operator-induced coupling** — Structural operators act on the covariance to encode interaction and correlation effects.  
3. **Memory modulation** — Memory variables influence how strongly these operators act at any given time.  

At a high level, the covariance drift can be viewed as stabilizing, structure-aware, and modulated by memory.

### 4.2 Code Realization

In the implementation:

- drift terms are computed in-place  
- covariance operators act on the reshaped matrix form of the state  
- memory variables enter multiplicatively through parameterized kernels  

All drift logic resides in:

- `drift.jl`  
- `operators.jl`  
- `state.jl`  

The function signature follows SciML conventions and is compatible with `SDEProblem`.

## 5. Diffusion Dynamics

### 5.1 Design Requirements

Stochastic forcing must satisfy strict constraints:

- preserve symmetry of the covariance  
- avoid destroying positive definiteness  
- integrate cleanly with the lifted formulation  

As a result, noise is **not injected directly** into arbitrary matrix entries.

### 5.2 Structured Diffusion

In the model:

- diffusion acts through structured operators  
- noise may enter through memory variables  
- covariance noise is filtered through matrix transformations  

This results in **hypoelliptic dynamics**, where randomness spreads through the system indirectly rather than acting isotropically.

### 5.3 Code Realization

Diffusion terms are implemented in `diffusion.jl`.  

The diffusion function:

- produces noise compatible with the flattened state  
- respects symmetry by construction  
- scales noise using `σψ`, `ε`, and `U`  

## 6. Memory Dynamics

### 6.1 Purpose of Memory Variables

Memory variables encode **persistent temporal dependence** without explicit history tracking. They:

- relax on a timescale controlled by `η`  
- modulate covariance dynamics  
- introduce long autocorrelation tails  

### 6.2 Memory Kernel

The current implementation uses an **exponential memory kernel**, meaning:

- memory decays continuously over time  
- larger `η` corresponds to slower decay (longer memory)  
- smaller `η` leads to faster mixing  

This choice balances simplicity, stability, and expressiveness.

### 6.3 Code Realization

Memory dynamics are implemented in:

- `state.jl`  
- `drift.jl`  

They evolve as part of the same SDE system, ensuring Markovian structure and compatibility with numerical solvers.

## 7. Initial Conditions

The initial state is constructed as follows:

- covariance initialized to $\bar{C}$ or a user-provided SPD matrix  
- memory variables initialized to zero  

This choice ensures:

- initial geometric consistency  
- reproducible behavior  
- clean interpretation of transient dynamics  

## 8. SDE Problem Construction

The full model is exposed through a helper function that constructs an `SDEProblem`:

- the flattened state is passed to SciML  
- drift and diffusion functions are bound  
- time span and parameters are fixed  

This abstraction allows users to:

- swap solvers  
- control time stepping  
- collect diagnostics  

## 9. Numerical Solvers

The model is solver-agnostic. In practice:

- Euler–Maruyama is used for validation  
- higher-order solvers can be substituted  
- solver choice affects accuracy and efficiency, not model structure  

## 10. Summary

The model implemented in **CovarianceDynamics.jl** is defined by:

- a lifted Markovian state including covariance and memory  
- structured drift enforcing stability and geometry  
- structured diffusion introducing stochasticity safely  
- explicit parameterization controlling memory and noise  

Every component described here maps directly to code, and no part of the implementation relies on undocumented behavior or implicit assumptions.
