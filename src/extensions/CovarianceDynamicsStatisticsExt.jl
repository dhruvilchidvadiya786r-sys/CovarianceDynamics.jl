
module CovarianceDynamicsStatisticsExt

using CovarianceDynamics
using Statistics

# Re-export Statistics functionality used by the package
CovarianceDynamics._mean(x) = mean(x)

end
