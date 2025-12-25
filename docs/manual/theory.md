# Mathematical Framework

This section presents the mathematical framework underlying **CovarianceDynamics.jl**. The goal is to define the objects, state space, and stochastic structure **precisely**, while avoiding unnecessary formalism.  

No claims of full analytical completeness are made here. Instead, this section establishes a **consistent and well-posed mathematical setting** that explains the design of the implementation and the numerical behavior observed in experiments.

## 1. State Space

### 1.1 Covariance Component

Let $\mathcal{S}_{++}^n$ denote the space of real symmetric positive-definite $n \times n$ matrices.

At each time $t$, the primary state variable is a covariance matrix

$$
C_t \in \mathcal{S}_{++}^n.
$$

This space is a smooth manifold but **not a vector space**. As a result, stochastic dynamics must be constructed with care to avoid leaving $\mathcal{S}_{++}^n$.

### 1.2 Memory Component

To model non-Markovian effects, the system is augmented with auxiliary **memory variables**. These variables encode past influence in a controlled, finite-dimensional way.

The combined state is written abstractly as

$$
X_t = (C_t, M_t),
$$

where:

- $C_t$ is the covariance component  
- $M_t$ represents one or more memory variables  

The inclusion of $M_t$ allows the overall system to be **Markovian** even though the effective dynamics of $C_t$ exhibit memory.

## 2. Markovian Lift of Non-Markovian Dynamics

### 2.1 Motivation

Directly defining stochastic dynamics with explicit history dependence is numerically impractical and incompatible with standard SDE solvers.

Instead, a **Markovian lift** is employed:

- memory is encoded via auxiliary variables  
- the lifted system is Markovian  
- standard stochastic analysis applies  

This approach preserves both computational tractability and the qualitative effects of memory.

### 2.2 Lifted Dynamics (Abstract Form)

The lifted system evolves according to a stochastic differential equation of the form:

$$
\mathrm{d}X_t = \mathcal{F}(X_t)\, \mathrm{d}t + \mathcal{G}(X_t)\, \mathrm{d}W_t,
$$

where:

- $X_t = (C_t, M_t)$  
- $\mathcal{F}$ is the drift of the lifted system  
- $\mathcal{G}$ is the diffusion operator  
- $W_t$ is a standard Brownian motion of appropriate dimension  

Crucially, the components of $\mathcal{F}$ and $\mathcal{G}$ are constructed so that the covariance component remains in $\mathcal{S}_{++}^n$.

## 3. Drift Structure

The drift of the covariance component incorporates three interacting effects:

1. **Mean reversion** toward a reference covariance $\bar{C}$  
2. **Coupling to memory variables**  
3. **Structural operators enforcing geometric consistency**  

At a conceptual level, the drift may be viewed as:

- pulling the covariance toward a baseline  
- modulated by memory-dependent operators  
- without introducing arbitrary linear perturbations  

The exact algebraic form is specified in `model.md`, where each term is mapped directly to code.

## 4. Diffusion Structure

Stochastic forcing enters the system through structured diffusion terms.

Key design requirements are:

- noise must preserve symmetry  
- noise must not destroy positive definiteness  
- diffusion may act indirectly through memory variables  

Rather than injecting unconstrained matrix noise, stochastic forcing is filtered through operators compatible with the lifted state structure.

This leads to **hypoelliptic dynamics**, in which:

- noise does not act in all directions directly  
- but regularization occurs through coupling  

## 5. Well-Posedness Considerations

A full analytical proof of existence and uniqueness is beyond the scope of this documentation. However, the following structural properties support well-posedness:

- smooth drift and diffusion coefficients  
- finite-dimensional Markovian formulation  
- absence of explicit history dependence  
- controlled noise injection  

These properties ensure compatibility with standard numerical solvers and justify the use of established SDE integration methods.

## 6. Invariance of the SPD Manifold

The lifted dynamics are constructed so that:

- symmetry of $C_t$ is preserved  
- positive definiteness is not violated under numerical evolution  
- no projection or correction is required during simulation  

This invariance is not claimed as a proven theorem here, but is supported by extensive numerical validation documented in later sections.

## 7. Long-Time Behavior

The lifted system defines a Markov process on an extended state space.

Numerical experiments indicate that:

- trajectories remain bounded over long time horizons  
- time averages converge  
- correlations decay slowly but eventually vanish  

These observations are consistent with the existence of an invariant probability measure for the lifted process.

## 8. Scope of Theoretical Claims

To avoid overstatement, we emphasize that:

- no explicit invariant measure is derived  
- no quantitative mixing rates are proven  
- ergodicity is supported by numerical evidence only  

The purpose of this framework is to provide a **correct and extensible mathematical setting**, not a closed theoretical result.

## 9. Summary

The theory underlying **CovarianceDynamics.jl** is based on:

- stochastic dynamics on the SPD manifold  
- auxiliary-variable formulations for memory  
- Markovian lifts of non-Markovian behavior  
- structured drift and diffusion operators  

This framework explains the qualitative behavior observed in simulations and provides a foundation for future analytical and numerical work.
