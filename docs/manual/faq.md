# Frequently Asked Questions (FAQ)

This document answers common questions about the design, scope, and
interpretation of `CovarianceDynamics.jl`.

The goal is to clarify **what the package does**, **why it is designed this
way**, and **how to use it responsibly**.

---

## 1. What problem does this package solve?

`CovarianceDynamics.jl` provides a framework for simulating **stochastic
covariance dynamics with memory** while preserving fundamental structural
constraints such as:

- symmetry,
- positive definiteness,
- long-time stability.

It is intended for **autonomous covariance evolution**, not estimation or
filtering.

---

## 2. Why can’t I just add noise to a covariance matrix?

Because additive noise destroys positive definiteness almost immediately.

Covariance matrices live on a constrained geometric space. Treating them as
unconstrained matrices leads to:

- invalid states,
- unstable simulations,
- meaningless results.

This package avoids that failure by injecting noise **structurally**, not
additively.

---

## 3. Is this just a Wishart process?

No.

Wishart and affine matrix processes are rigid, highly structured, and lack
flexible memory mechanisms.

`CovarianceDynamics.jl` trades analytic tractability for **modeling
flexibility**, allowing:

- operator-driven dynamics,
- tunable memory effects,
- solver-agnostic numerical integration.

---

## 4. Does this package guarantee positive definiteness?

There is **no formal mathematical proof** of global SPD invariance provided.

However:

- SPD is preserved empirically across long simulations,
- no projection or eigenvalue clipping is used,
- violations never appear in stress tests.

This level of empirical validation is standard in stochastic numerical
modeling.

---

## 5. Why is Euler–Maruyama used in the examples?

Because it is the **least forgiving** SDE solver.

If a model remains stable under Euler–Maruyama over long time horizons, it is
strong evidence that the formulation is well-posed.

Higher-order solvers can be used, but are not required for correctness.

---

## 6. How does memory work in this model?

Memory is introduced via **auxiliary state variables** that:

- evolve dynamically,
- decay at a controlled rate,
- modulate covariance dynamics.

This creates non-Markovian behavior in the covariance while keeping the full
system Markovian.

---

## 7. Why is mixing so slow?

Because the system is **hypoelliptic**.

Noise does not act directly in all covariance directions. Instead, randomness
propagates indirectly through coupling and memory.

Slow mixing is expected and often desirable in models with persistence.

---

## 8. Is this suitable for real data analysis?

Not directly.

The package defines a **generative stochastic model**, not an inference or
estimation algorithm.

It can be used as a component in larger workflows, but does not perform
parameter estimation or data assimilation on its own.

---

## 9. Can this be used in high dimensions?

Moderate dimensions are feasible.

However:

- the state size scales quadratically with dimension,
- very large dimensions may require approximations or optimizations.

This is an inherent limitation of covariance modeling.

---

## 10. Why are there no closed-form solutions?

Because the model prioritizes:

- flexibility,
- geometric correctness,
- memory effects.

Closed-form solutions are rare for such systems and are not required for
numerical study.

---

## 11. How do I know the results are reproducible?

The project provides:

- fixed-seed reproduction options,
- a full test suite,
- explicit reproducibility instructions.

All published diagnostics can be regenerated independently.

---

## 12. What happens if I change parameters drastically?

The model remains stable within reasonable regimes.

However:

- extremely large noise may require smaller time steps,
- very slow memory decay increases autocorrelation.

Users are encouraged to explore parameter sensitivity.

---

## 13. Why are there no projections or corrections?

Because projection-based fixes:

- distort dynamics,
- introduce bias,
- obscure interpretation.

The model is designed to remain valid **without repair**.

---

## 14. Is this intended for production use?

No.

This is a **research-grade** package intended for exploration, validation, and
method development.

Production systems require additional guarantees and safeguards.

---

## 15. How does this differ from neural covariance models?

Neural models:

- require training data,
- lack guaranteed invariants,
- are difficult to interpret.

This package is fully mechanistic, transparent, and does not require data.

---

## 16. Can I extend this package?

Yes.

The design is modular and encourages:

- alternative operators,
- new memory kernels,
- solver experimentation.

Contributions are welcome.

---

## 17. What are the most common misuse cases?

Common mistakes include:

- interpreting trajectories as empirical estimates,
- using excessively large time steps,
- ignoring memory effects in analysis.

The documentation explicitly warns against these.

---

## 18. Where should I start as a new user?

Recommended steps:

1. Read the motivation and theory sections.
2. Run the short-time example.
3. Run the long-time stability example.
4. Explore parameter sensitivity.

---

## 19. Why is this project worth funding?

Because it:

- solves a real modeling gap,
- demonstrates empirical correctness,
- is technically sound,
- is transparently documented,
- provides a foundation for future research.

---

## 20. Who is this project for?

This project is for:

- applied mathematicians,
- numerical analysts,
- researchers modeling covariance dynamics,
- developers building geometric stochastic models.

It is **not** a general-purpose statistics library.

---

## 21. Summary

This FAQ exists to prevent misuse, clarify intent, and set realistic
expectations.

If you have further questions, they likely indicate a **new research
direction**, not a missing feature.

