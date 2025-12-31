###############################################################################
# full_verification_script.jl
#
# CovarianceDynamics.jl — Full Verification Script
#
# PURPOSE
# -------
# This script provides a single, explicit entry point to reproduce the
# full validation of CovarianceDynamics.jl:
#
#   1. Environment setup check
#   2. Official unit test suite
#   3. Core validation diagnostics (no plots)
#
# This script is intended for:
#   - SciML maintainers
#   - NumFOCUS reviewers
#   - Research reproducibility audits
#
# IMPORTANT
# ---------
# • This script does NOT suppress failures.
# • This script does NOT assert scientific claims.
# • This script only orchestrates existing tests and diagnostics.
#
# All scientific interpretation is documented in validation/*.md files.
###############################################################################

using Pkg
using Printf
using Dates

# ---------------------------------------------------------------------------
# 1. Header
# ---------------------------------------------------------------------------

println("══════════════════════════════════════════════════════════════")
println("  CovarianceDynamics.jl — Full Verification")
println("  Date      : ", Dates.now())
println("  Julia     : ", VERSION)
println("══════════════════════════════════════════════════════════════\n")

# ---------------------------------------------------------------------------
# 2. Activate and Instantiate Environment
# ---------------------------------------------------------------------------

println("▶ Activating project environment...")
Pkg.activate(".")
Pkg.instantiate()
println("✓ Environment ready\n")

# ---------------------------------------------------------------------------
# 3. Load Core Dependencies
# ---------------------------------------------------------------------------

println("▶ Loading core packages...")
using CovarianceDynamics
using DifferentialEquations
using LinearAlgebra
using Statistics
using Random
println("✓ Packages loaded successfully\n")

# ---------------------------------------------------------------------------
# 4. Run Official Unit Test Suite
# ---------------------------------------------------------------------------

println("▶ Running official unit test suite (Pkg.test)...")

test_ok = true
try
    Pkg.test("CovarianceDynamics"; coverage=false)
catch e
    test_ok = false
    println("\n✗ Unit test suite failed with error:")
    showerror(stdout, e)
    println("\n")
end

if test_ok
    println("✓ Unit test suite completed successfully\n")
else
    println("✗ Unit test suite reported failures\n")
end

# ---------------------------------------------------------------------------
# 5. Validation Diagnostics (Sequential, Explicit)
# ---------------------------------------------------------------------------

println("▶ Running validation diagnostics (non-CI, empirical)...\n")

diagnostics = [
    ("Long-time stability", "experiments/long_time_run.jl"),
    ("Stress and failure modes", "experiments/stress_test.jl"),
    ("Memory and mixing behavior", "experiments/mixing_rate_estimation.jl"),
    ("Projection vs no-projection", "experiments/projection_vs_no_projection.jl"),
    ("Solver comparison", "experiments/solver_comparison.jl")
]

diagnostic_results = Dict{String,Bool}()

for (name, path) in diagnostics
    println("— Diagnostic: $name")
    println("  Script    : $path")

    ok = true
    try
        include(path)
    catch e
        ok = false
        println("  ✗ Diagnostic failed:")
        showerror(stdout, e)
        println()
    end

    diagnostic_results[name] = ok

    if ok
        println("  ✓ Completed successfully\n")
    else
        println("  ✗ Encountered errors\n")
    end
end

# ---------------------------------------------------------------------------
# 6. Summary Report
# ---------------------------------------------------------------------------

println("══════════════════════════════════════════════════════════════")
println("  Verification Summary")
println("══════════════════════════════════════════════════════════════")

@printf("Unit test suite              : %s\n",
        test_ok ? "PASS" : "FAIL")

for (name, ok) in diagnostic_results
    @printf("Diagnostic %-22s : %s\n",
            name,
            ok ? "PASS" : "FAIL")
end

println("\nNotes:")
println("• PASS indicates successful execution without runtime errors.")
println("• FAIL indicates numerical or runtime issues that must be")
println("  interpreted using validation documentation.")
println("• Diagnostic PASS does NOT imply mathematical guarantees.")

println("\nFor interpretation of results, see:")
println("  validation/README.md")
println("  validation/validation_manifest.md")
println("  validation/results/")

println("\n══════════════════════════════════════════════════════════════")
println("  End of Verification")
println("══════════════════════════════════════════════════════════════")
