###############################################################################
# runtests.jl
#
# Entry point for the CovarianceDynamics.jl test suite.
#
# This file:
#   - initializes the test environment
#   - loads shared test utilities
#   - includes all test files in a deterministic order
#
# IMPORTANT:
#   - No test logic belongs here.
#   - No randomness is defined here.
#   - No assertions are written here.
###############################################################################

using Test
using CovarianceDynamics

# -----------------------------
# Shared test utilities
# -----------------------------
include("_test_utils.jl")

# -----------------------------
# Test set orchestration
# -----------------------------
@testset "CovarianceDynamics.jl" begin

    @testset "SPD Invariance" begin
        include("test_spd_invariance.jl")
    end

    @testset "Lyapunov Stability" begin
        include("test_lyapunov.jl")
    end

    @testset "Markov Lift Structure" begin
        include("test_markov_lift.jl")
    end

    @testset "Reproducibility" begin
        include("test_reproducibility.jl")
    end

end

