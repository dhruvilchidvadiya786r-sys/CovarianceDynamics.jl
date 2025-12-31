name: Bug Report
about: Report a bug, numerical issue, or unexpected behavior in CovarianceDynamics.jl
title: "[BUG] "
labels: ["bug"]
assignees: []

###############################################################################
# Issue Form Body
###############################################################################
body:

  ###########################################################################
  # Intro / Guidance
  ###########################################################################
  - type: markdown
    attributes:
      value: |
        ## Bug Report — CovarianceDynamics.jl

        Thank you for taking the time to report an issue.

        This project is **research-grade numerical software**.
        Some numerical failures are expected in *extreme or adversarial regimes*.
        This form is designed to help us distinguish:

        - implementation bugs
        - numerical instability
        - documented limitations

        Please read and answer carefully — **reproducibility is essential**.

  ###########################################################################
  # Bug Summary
  ###########################################################################
  - type: textarea
    id: summary
    attributes:
      label: Bug summary
      description: |
        Provide a **clear and concise description** of the issue.

        Examples:
        - Loss of SPD in a regime expected to be stable
        - Non-reproducible behavior with fixed RNG seed
        - Unexpected divergence or NaNs
      placeholder: |
        Brief description of what went wrong and why you believe it is a bug.
    validations:
      required: true

  ###########################################################################
  # Expected Behavior
  ###########################################################################
  - type: textarea
    id: expected_behavior
    attributes:
      label: Expected behavior
      description: |
        What did you expect to happen?

        Be explicit:
        - Which invariant should hold?
        - Which property was expected to remain valid?
      placeholder: |
        Describe the expected behavior.
    validations:
      required: true

  ###########################################################################
  # Observed Behavior
  ###########################################################################
  - type: textarea
    id: observed_behavior
    attributes:
      label: Observed behavior
      description: |
        What actually happened?

        Include:
        - error messages
        - numerical pathologies (e.g. loss of SPD, NaNs)
        - unexpected qualitative behavior
      placeholder: |
        Describe the observed behavior.
    validations:
      required: true

  ###########################################################################
  # Minimal Reproducible Example
  ###########################################################################
  - type: textarea
    id: reproducible_example
    attributes:
      label: Minimal reproducible example
      description: |
        Provide a **minimal Julia script** that reproduces the issue.

        Requirements:
        - Use a fixed RNG seed
        - Avoid plots
        - Keep runtime short
      placeholder: |
        using CovarianceDynamics
        using DifferentialEquations
        using Random

        Random.seed!(123)

        # minimal example here
      render: julia
    validations:
      required: true

  ###########################################################################
  # Environment Information
  ###########################################################################
  - type: input
    id: julia_version
    attributes:
      label: Julia version
      placeholder: "e.g. 1.10.4"
    validations:
      required: true

  - type: input
    id: os
    attributes:
      label: Operating system
      placeholder: "Linux / macOS / Windows"
    validations:
      required: true

  - type: input
    id: package_version
    attributes:
      label: CovarianceDynamics.jl version or commit hash
      placeholder: "e.g. v0.1.0 or commit SHA"
    validations:
      required: true

  - type: input
    id: solver
    attributes:
      label: Solver used
      placeholder: "e.g. EM, SOSRI"
    validations:
      required: true

  - type: input
    id: timestep
    attributes:
      label: Time step (dt)
      placeholder: "e.g. 1e-3"
    validations:
      required: true

  ###########################################################################
  # Regime Classification
  ###########################################################################
  - type: dropdown
    id: regime
    attributes:
      label: Regime classification
      description: |
        Help us classify the issue.
        Some failures are expected in adversarial regimes.
      options:
        - Benign / validated regime
        - Stress / adversarial regime
        - Extreme noise or coarse discretization
        - Unsure
    validations:
      required: true

  ###########################################################################
  # Reproducibility Checklist
  ###########################################################################
  - type: checkboxes
    id: reproducibility
    attributes:
      label: Reproducibility checklist
      description: |
        Please confirm the following.
      options:
        - label: I can reproduce this issue with a fixed RNG seed
          required: true
        - label: I ran `Pkg.activate("."); Pkg.instantiate()` before testing
          required: true
        - label: I searched existing issues before opening this report
          required: true

  ###########################################################################
  # Relation to Known Limitations
  ###########################################################################
  - type: textarea
    id: limitations
    attributes:
      label: Relation to documented limitations (if any)
      description: |
        Does this issue relate to anything described in `limitations.md`?
        If unsure, leave blank.
      placeholder: |
        e.g. Possible relation to Euler–Maruyama discretization limits.
    validations:
      required: false

  ###########################################################################
  # Final Notes
  ###########################################################################
  - type: markdown
    attributes:
      value: |
        ### Notes for contributors

        - Numerical instability in extreme regimes may be expected behavior.
        - Please do **not** attach plots unless explicitly requested.
        - Clear, reproducible reports are prioritized.

        Thank you for helping improve CovarianceDynamics.jl.
