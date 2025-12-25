# References and Prior Work

This section documents the **theoretical, numerical, and conceptual foundations**
that inform the design of `CovarianceDynamics.jl`.

The project does not claim to rederive these works, nor does it attempt to
subsume them. Instead, it builds upon well-established ideas from stochastic
analysis, numerical SDEs, matrix-valued processes, and geometric modeling, while
addressing a specific gap: **stable stochastic covariance dynamics with memory**.

---

## 1. Stochastic differential equations (general)

The numerical and conceptual framework of this project is grounded in the
classical theory of stochastic differential equations.

- Øksendal, B.  
  *Stochastic Differential Equations: An Introduction with Applications*.  
  Springer, 6th edition, 2003.

- Karatzas, I., Shreve, S.  
  *Brownian Motion and Stochastic Calculus*.  
  Springer, 2nd edition, 1991.

These texts provide the foundational language for drift–diffusion systems and
Itô calculus used throughout the project.

---

## 2. Numerical methods for SDEs

The discretization strategy and solver choices follow standard numerical SDE
practice.

- Kloeden, P. E., Platen, E.  
  *Numerical Solution of Stochastic Differential Equations*.  
  Springer, 1992.

- Higham, D. J.  
  “An Algorithmic Introduction to Numerical Simulation of Stochastic Differential
  Equations.”  
  *SIAM Review*, 43(3), 2001.

These references justify the use of Euler–Maruyama as a baseline solver and
clarify the limitations of explicit schemes.

---

## 3. Matrix-valued and covariance processes

Covariance dynamics and matrix-valued stochastic processes have a long history,
particularly in finance and signal processing.

- Bru, M.-F.  
  “Wishart Processes.”  
  *Journal of Theoretical Probability*, 4(4), 1991.

- Gourieroux, C., Sufana, R.  
  “Wishart Quadratic Term Structure Models.”  
  *Journal of Financial Econometrics*, 1(2), 2003.

These works guarantee positive definiteness but impose strong parametric
constraints and lack flexible memory mechanisms.

---

## 4. Geometry of symmetric positive definite matrices

The geometric structure of SPD matrices motivates the invariant-preserving design
of the model.

- Bhatia, R.  
  *Positive Definite Matrices*.  
  Princeton University Press, 2007.

- Moakher, M., Batchelor, P.  
  “Symmetric Positive-Definite Matrices: From Geometry to Applications.”  
  In *Visualization and Processing of Tensor Fields*, Springer, 2006.

These references explain why naïve linear dynamics are incompatible with SPD
constraints.

---

## 5. Hypoellipticity and degenerate noise

The slow mixing and structured noise behavior observed in this project are
consistent with hypoelliptic systems.

- Hörmander, L.  
  “Hypoelliptic Second Order Differential Equations.”  
  *Acta Mathematica*, 1967.

- Pavliotis, G. A.  
  *Stochastic Processes and Applications*.  
  Springer, 2014.

These works provide the theoretical background for indirect noise propagation and
non-uniform mixing.

---

## 6. Memory effects and non-Markovian dynamics

Non-Markovian effects are incorporated through Markovian lifting, a standard
approach in stochastic modeling.

- Kupferman, R.  
  “Fractional Kinetics in Kac–Zwanzig Heat Bath Models.”  
  *Journal of Statistical Physics*, 2004.

- Pavliotis, G. A., Stuart, A. M.  
  *Multiscale Methods: Averaging and Homogenization*.  
  Springer, 2008.

These references motivate the use of auxiliary variables to encode memory while
maintaining Markovian structure.

---

## 7. Scientific computing and the SciML ecosystem

The implementation relies on established practices from the Julia scientific
computing ecosystem.

- Rackauckas, C., Nie, Q.  
  “DifferentialEquations.jl – A Performant and Feature-Rich Ecosystem for Solving
  Differential Equations in Julia.”  
  *Journal of Open Research Software*, 2017.

- Rackauckas, C. et al.  
  “Universal Differential Equations for Scientific Machine Learning.”  
  *arXiv preprint*, 2020.

These works justify solver abstraction, in-place computations, and composable
model design.

---

## 8. What this project does *not* rely on

For clarity, `CovarianceDynamics.jl` does **not** rely on:

- closed-form analytic covariance solutions,
- neural or data-driven covariance models,
- projection-based geometric integration,
- ad-hoc numerical repair mechanisms.

This distinguishes the project from several existing approaches.

---

## 9. Relationship to existing literature

The present project sits at the intersection of:

- stochastic covariance modeling,
- geometric numerical methods,
- memory-augmented dynamical systems.

While each component is well studied individually, their combination in a
numerically stable, open-source framework is comparatively underdeveloped.

---

## 10. Citation guidance

If you use `CovarianceDynamics.jl` in academic work, please cite:

- the software repository,
- the relevant documentation sections,
- and any underlying theoretical references appropriate to your application.

A `CITATION.cff` file is provided to facilitate proper attribution.

---

## 11. Summary

The references listed here provide the intellectual foundation for
`CovarianceDynamics.jl`.

The project does not attempt to replace existing theory. Instead, it
demonstrates how established ideas can be combined to address a practical and
previously underserved modeling problem in stochastic covariance dynamics.

