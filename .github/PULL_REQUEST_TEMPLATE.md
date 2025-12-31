# Pull Request

Thank you for contributing to **CovarianceDynamics.jl**.

This project is **research-grade numerical software**. Pull requests are reviewed
for **correctness, validation impact, and long-term maintainability**.

Please complete the sections below carefully.

---

## Summary

Provide a concise description of the change.

- What does this PR do?
- Why is it needed?
- Which part of the codebase is affected?

---

## Type of Change

Select all that apply:

- [ ] Bug fix (no change in intended behavior)
- [ ] Documentation update
- [ ] Refactor (no functional change)
- [ ] New feature / extension
- [ ] Validation / diagnostics update
- [ ] Maintenance / infrastructure

---

## Scientific and Conceptual Context

Explain how this change aligns with the **core scope** of the project:

- covariance-matrix-valued dynamics
- memory / non-Markovian modeling
- stochastic numerical methods
- validation and reproducibility

If this change is **out of scope**, please justify why it belongs here.

---

## Implementation Details

Describe the implementation at a high level:

- key functions or files modified,
- new parameters or state variables (if any),
- assumptions introduced or removed.

Avoid pasting large code blocks unless necessary.

---

## Validation Impact (Required)

Does this change affect validation?

- [ ] No (pure refactor / docs only)
- [ ] Yes — existing tests updated
- [ ] Yes — new tests added
- [ ] Yes — validation documentation updated

If **Yes**, specify:

- which tests were added or modified,
- which validation documents were updated
  (e.g. `validation_manifest.md`, `guarantees.md`, `limitations.md`).

---

## Test Results

Please confirm:

- [ ] `Pkg.test("CovarianceDynamics")` passes locally
- [ ] Tests are deterministic (fixed RNG seeds where applicable)
- [ ] No long-running experiments were added to CI

If tests fail or are skipped, explain why.

---

## Reproducibility

For stochastic changes:

- [ ] RNG usage is explicit
- [ ] Results are reproducible under fixed seeds
- [ ] No hidden global state is introduced

---

## Backward Compatibility

Does this PR introduce breaking changes?

- [ ] No
- [ ] Yes (please describe)

If **Yes**, explain:
- what breaks,
- why it is necessary,
- how users should migrate.

---

## Performance Considerations

Does this change affect performance?

- [ ] No
- [ ] Yes (please explain)

If applicable, describe expected impact and any mitigation.

---

## Documentation

- [ ] Documentation updated (README / docs / validation)
- [ ] No documentation changes needed

If documentation was updated, list the files.

---

## Checklist (Before Submitting)

- [ ] I ran the unit test suite locally
- [ ] I considered validation and reproducibility
- [ ] I reviewed `limitations.md` for scope consistency
- [ ] I did not introduce new claims without evidence
- [ ] I understand this project prioritizes correctness over features

---

## Notes for Reviewers

Anything specific you would like reviewers to focus on?
(e.g. numerical assumptions, edge cases, validation choices)

---

### Maintainer Notes (Internal)

(For maintainers to fill in during review.)
