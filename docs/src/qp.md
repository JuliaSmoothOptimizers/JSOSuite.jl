# [Quadratic models with linear constraints](@id qp)

The quadratic model with linear constraints is another specific case where the objective function is quadratic and the constraints are linear.

```math
\begin{aligned}
\min \quad &  x^TQx + c^Tx + c_0  \\
& c_A \leq Ax \leq l_A, \\
& \ell \leq x \leq u,
\end{aligned}
```

This problem is convex whenever the matrix `Q` is positive semi-definite. A key aspect here is the modeling of the matrices `Q` and `A`. 
The main data structure available in Julia are: `LinearAlgebra.Matrix`, `SparseArrays.sparse`, `SparseMatricesCOO.sparse`, `LinearOperators.LinearOperator`.

In JuliaSmoothOptimizers, the package [`QuadraticModels.jl`](https://github.com/JuliaSmoothOptimizers/QuadraticModels.jl) can be used to access the NLPModel API for such instance.

The function `solve` with the following sets of arguments will automatically build a `QuadraticModel` and choose the adequate solver.

```julia
  stats = solve(c, H, c0 = c0, x0 = x0, name = name; kwargs...)
  stats = solve(c, H, lvar, uvar, c0 = c0, x0 = x0, name = name; kwargs...)
  stats = solve(c, H, A, lcon, ucon, c0 = c0, x0 = x0, name = name; kwargs...)
  stats = solve(c, H, lvar, uvar, A, lcon, ucon, c0 = c0, x0 = x0, name = name; kwargs...)
```

## Example

```@example ex1
  using SparseArrays
  n = 50
  c = zeros(n)
  H = spdiagm(0 => 1.0:n)
  H[n, 1] = 1.0
  A = ones(1, n)
  lcon = [1.0]
  ucon = [1.0]
```

The quadratic model can then be solved using [`solve`](@ref).

```@example ex1
using JSOSuite
  stats = solve(c, H, A, lcon, ucon, name = "eqconqp_QP")
```

This is equivalent to building a `QuadraticModel` and then [`solve`](@ref).

```@example ex1
using QuadraticModels, JSOSuite
  qp_model = QuadraticModel(c, H, A, lcon, ucon, name = "eqconqp_QP")
  stats = solve(qp_model)
```

As usual, it is also possible to select manually the solver to be used.

```@example ex1
  stats = solve("RipQP", c, H, A, lcon, ucon, name = "eqconqp_QP")
```
