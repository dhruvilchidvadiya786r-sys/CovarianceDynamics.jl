---
name: Feature Request
about: Propose a new feature, extension, or research direction
title: "[FEATURE] "
labels: enhancement
assignees: ''
---

## Summary

Provide a **concise description** of the proposed feature.

- What is being added or changed?
- Is this a new capability, an extension, or a refinement?

---

## Motivation

Explain **why this feature is needed**.

Address at least one of the following:
- a limitation in the current model,
- a missing research capability,
- a use case not currently supported.

Be specific and research-oriented.

---

## Conceptual Alignment (Required)

How does this feature relate to the **core scope** of `CovarianceDynamics.jl`?

Check all that apply and explain briefly:

- [ ] Covariance-matrix-valued dynamics
- [ ] Memory / non-Markovian effects
- [ ] Stochastic modeling
- [ ] Numerical analysis or solver behavior
- [ ] Validation / diagnostics / reproducibility
- [ ] Other (please explain)

Features that do not align with the above may be out of scope.

---

## Proposed Approach

Describe **how** you believe this feature could be implemented.

You do **not** need to provide code, but please address:
- conceptual design,
- new parameters or state variables (if any),
- interaction with existing components.

---

## Validation Impact (Important)

Does this feature require **new validation**?

Please consider:
- new unit tests,
- new diagnostics or experiments,
- updates to `validation_manifest.md`,
- changes to guarantees or limitations.

Explain what would need to be validated.

---

## Alternatives Considered

Have you considered:
- alternative formulations?
- implementing this externally?
- using existing tools in the SciML ecosystem?

Explain briefly.

---

## Backward Compatibility

Would this feature:
- break existing APIs?
- change default behavior?
- alter existing guarantees?

If yes, explain how compatibility would be preserved or why breaking changes are justified.

---

## Scope and Priority

How critical is this feature?

- [ ] Experimental / exploratory
- [ ] Useful but optional
- [ ] Important for research completeness
- [ ] Essential for core functionality

---

## Additional Context

Optional:
- links to papers or references,
- related issues or discussions,
- example use cases.

---

## Checklist (Before Submitting)

- [ ] I understand this is a **research-grade** project
- [ ] I checked existing issues and documentation
- [ ] I considered validation and maintenance impact
- [ ] I understand that not all feature requests will be accepted

---

## Notes for Maintainers

(Anything you want maintainers to focus on when reviewing this request.)
