export fminunc

"""
    fminunc(f, x₀)

Minimize f starting from the point x₀.

$OPTIONS_STRING
"""
function fminunc(f, x :: AbstractVector;
                 solver :: Symbol = :lbfgs,
                 atol :: Real = 1e-8,
                 rtol :: Real = 1e-8,
                 max_eval :: Int = -1,
                 max_time :: Float64 = 30.0,
                 verbose :: Bool = false,
                 logger = verbose ? ConsoleLogger() : NullLogger()
                )
  with_logger(logger) do
    solver_list[solver](ADNLPModel(f, x); atol=atol, rtol=rtol, max_eval=max_eval, max_time=max_time)
  end
end
