"""
diagnostics.jl

Diagnostics and analysis tools for CovarianceDynamics.jl.

This file provides read-only utilities to:
- measure Lyapunov decay
- track spectral properties of the covariance
- evaluate time averages
- quantify ergodicity and mixing behavior

No state mutation, no solvers, and no callbacks
are implemented here.
"""

using LinearAlgebra
using Statistics

# ============================================================
# 1. Lyapunov Trajectory
# ============================================================

"""
    lyapunov_trajectory(sol, p)

Compute the Lyapunov function along a solution trajectory.

Returns a vector V(tᵢ).
"""
function lyapunov_trajectory(sol, p::CovMemoryParams)
    return [lyapunov(u, p) for u in sol.u]
end


# ============================================================
# 2. Spectral Diagnostics
# ============================================================

"""
    min_eigen_trajectory(sol, p)

Return the minimum eigenvalue of the covariance matrix
along the trajectory.
"""
function min_eigen_trajectory(sol, p::CovMemoryParams)
    return [
        minimum(eigvals(Symmetric(get_covariance(u, p))))
        for u in sol.u
    ]
end


"""
    condition_number_trajectory(sol, p)

Return the condition number of the covariance matrix
along the trajectory.
"""
function condition_number_trajectory(sol, p::CovMemoryParams)
    return [
        cond(Symmetric(get_covariance(u, p)))
        for u in sol.u
    ]
end


# ============================================================
# 3. Time Averages
# ============================================================

"""
    time_average(sol, f)

Compute the time average of a scalar observable f.

f must act on structured CovMemoryState.
"""
function time_average(sol, f)
    values = [f(unflatten_state(u, sol.prob.p)) for u in sol.u]
    return mean(values)
end


"""
    time_average(sol, p, f)

Compute the time average of a function f(u, p).
"""
function time_average(sol, p::CovMemoryParams, f)
    values = [f(u, p) for u in sol.u]
    return mean(values)
end


# ============================================================
# 4. Ergodicity Diagnostics
# ============================================================

"""
    ergodicity_error(sol, p, f)

Estimate the empirical ergodicity error:

    sup_t | (1/t) ∫₀ᵗ f(X_s) ds − ⟨f⟩ |

Approximated using discrete time averages.
"""
function ergodicity_error(sol, p::CovMemoryParams, f)
    vals = [f(u, p) for u in sol.u]
    running_avg = cumsum(vals) ./ (1:length(vals))
    return maximum(abs.(running_avg .- mean(vals)))
end


# ============================================================
# 5. Autocorrelation Diagnostics
# ============================================================

"""
    autocorrelation(x, lag)

Compute empirical autocorrelation at given lag.
"""
function autocorrelation(x::AbstractVector, lag::Int)
    n = length(x)
    μ = mean(x)
    denom = sum((x .- μ).^2)
    return sum((x[1:n-lag] .- μ) .* (x[lag+1:n] .- μ)) / denom
end


"""
    autocorrelation_trajectory(sol, p, f; maxlag=100)

Compute autocorrelation of observable f up to maxlag.
"""
function autocorrelation_trajectory(
    sol,
    p::CovMemoryParams,
    f;
    maxlag::Int = 100
)
    vals = [f(u, p) for u in sol.u]
    return [autocorrelation(vals, k) for k in 1:min(maxlag, length(vals)-1)]
end


# ============================================================
# 6. Consistency Report
# ============================================================

"""
    consistency_report(sol, p)

Return a summary of numerical consistency diagnostics.
"""
function consistency_report(sol, p::CovMemoryParams)
    return (
        lyapunov_mean = mean(lyapunov_trajectory(sol, p)),
        min_eigen_min = minimum(min_eigen_trajectory(sol, p)),
        condition_max = maximum(condition_number_trajectory(sol, p)),
        ergodicity_Lyapunov = ergodicity_error(sol, p, lyapunov)
    )
end

