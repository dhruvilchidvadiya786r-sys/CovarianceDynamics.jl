# Numerical Methods and Discretization Strategy

This section explains how the stochastic model implemented in **CovarianceDynamics.jl** is discretized and solved numerically, and why the observed results are reliable despite the complexity of the underlying geometry and memory structure.  

The emphasis is on **numerical faithfulness**, not formal convergence proofs.

## 1. Numerical Challenges of Covariance Dynamics

Simulating stochastic covariance dynamics presents several inherent difficulties:

- the state space is nonlinear (SPD manifold)  
- noise can easily destabilize the system  
- memory effects introduce long temporal correlations  
- long-time behavior is essential for validation  

A viable numerical scheme must therefore:

- remain stable over long horizons  
- preserve geometric invariants empirically  
- integrate smoothly with standard SDE solvers  

## 2. Discretization Framework

The model is discretized using **standard Itô SDE solvers** provided by the SciML ecosystem.

The continuous-time lifted system is represented numerically as:

- a flat real-valued state vector  
- with drift and diffusion evaluated in-place  
- under explicit time stepping  

No custom solver is introduced; instead, correctness is achieved through careful model construction.

## 3. Euler–Maruyama as a Validation Baseline

### 3.1 Choice of Solver

The primary solver used in validation experiments is the **Euler–Maruyama (EM)** scheme.  

This choice is deliberate:

- EM is simple and transparent  
- it exposes instability immediately if the model is ill-posed  
- it is widely understood and easy to reproduce  
- it avoids solver-induced artifacts  

If a model behaves well under Euler–Maruyama, it is strong evidence that the formulation itself is stable.

### 3.2 Time Step Selection

Simulations were performed with a fixed time step:

$$
\Delta t = 10^{-3}
$$

This step size was chosen to balance:

- numerical stability  
- computational feasibility  
- resolution of memory dynamics  

Reducing the time step further does not qualitatively change the observed behavior, indicating robustness.

## 4. Long-Time Integration

A defining feature of the numerical experiments is **long-time simulation**.  

Typical integration horizons include:

- short runs: $T = 1$  
- validation runs: $T = 50$  

These horizons are intentionally long relative to:

- memory decay times  
- mean-reversion scales  
- noise correlation times  

This exposes slow instabilities that short runs would miss.

## 5. Absence of Numerical Repair Mechanisms

A critical design choice is the **absence of numerical repair steps**:

- no projection onto the SPD cone  
- no eigenvalue clipping  
- no renormalization  

This means that:

- any violation of invariants would immediately appear  
- stability must arise from the dynamics, not post-processing  

The fact that long-time simulations remain well-behaved under these conditions is a strong numerical validation.

## 6. Stability Observations

Empirical numerical stability manifests as:

- bounded covariance trajectories  
- no explosive growth  
- no collapse toward singularity  
- smooth evolution over tens of thousands of steps  

These properties persist across parameter regimes and noise strengths tested.

## 7. Autocorrelation and Mixing Diagnostics

Numerical diagnostics reveal **slow but consistent mixing**:

- short-lag autocorrelations are close to one  
- correlations decay gradually with increasing lag  
- long-lag correlations drop significantly  

This behavior is expected from:

- memory-modulated dynamics  
- hypoelliptic noise structure  
- indirect stochastic forcing  

The observed decay confirms that the system is neither frozen nor chaotic, but exhibits controlled stochastic evolution.

## 8. Solver Agnosticism

Although Euler–Maruyama is used for validation, the formulation is **solver agnostic**:

- any SciML-compatible SDE solver may be substituted  
- higher-order solvers improve accuracy but not structure  
- solver choice does not alter invariant preservation  

This flexibility is a direct result of clean separation between model definition and numerical integration.

## 9. Reproducibility Considerations

Numerical reproducibility is ensured by:

- explicit time steps  
- fixed random seeds when required  
- explicit parameter specification  
- deterministic initial conditions  

All reported numerical behavior can be reproduced exactly given the same solver and parameters.

## 10. Limitations of the Numerical Approach

The following limitations are acknowledged:

- no formal convergence proof is provided  
- geometric invariance is empirical, not proven  
- very large dimensions may require adaptive solvers  
- extreme noise regimes may require finer discretization  

These limitations are intrinsic to stochastic geometric simulation and are documented transparently.

## 11. Summary

The numerical strategy of **CovarianceDynamics.jl** emphasizes:

- simplicity over sophistication  
- transparency over optimization  
- empirical stability over unverified theory  

The success of long-time Euler–Maruyama simulations without repair mechanisms provides strong evidence that the model is numerically sound and geometrically consistent.
