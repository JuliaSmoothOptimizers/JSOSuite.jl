# [Speed up Solvers Tips](@id speed-up)

The following contains a list of tips to speed up the solver selection and usage.

## Derivatives

The optimizers available in `JSOSuite.jl` are all using first and sometines second-order derivatives. There are mainly three categories:
- 1st order methods use only gradient information;
- 1st order quasi-Newton methods require only gradient information, and uses it to build an approximation of the Hessian;
- 2nd order methods: Those are using gradients and Hessian information.
- 2nd order methods matrix-free: Those are optimizers using Hessian information, but without ever forming the matrix, so only matrix-vector products are computed.

The latter is usually a good tradeoff for very large problems.

```@example
using JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
stats = solve(f, x0, verbose = 0, highest_derivative_available = 1)
stats
```

## Find a better initial guess

The majority of derivative-based optimizers are local methods whose performance are dependent of the initial guess. 
This usually relies on specific knowledge of the problem.

The function [`feasible_point`](@ref) computes a point satisfying the constraints of the problem that can be used as an initial guess. 
An alternative is to solve a simpler version of the problem and reuse the solution as an initial guess for the more complex one.

## Use the structure of the problem

If the problem has linear constraints, then it is efficient to specify it at the modeling stage to avoid having them treated like nonlinear ones.
Some of the optimizers will also exploit this information.

Similarly, quadratic objective or least squares problems have tailored modeling tools and optimizers.

## Change the parameters of the solver

Once a solver has been chosen it is also possible to play with the key parameters. Find below a list of the available optimizers and parameters.

Note that all optimizers presented here have been carefully optimized. All have different strengths. Trying another solver on the same problem sometimes provide a different solution.

### Unconstrained/Bound-constrained

##### LBFGS

- `mem::Int = 5`: memory parameter of the `lbfgs` algorithm;
- `τ₁::T = T(0.9999)`: slope factor in the Wolfe condition when performing the line search;
- `bk_max:: Int = 25`: maximum number of backtracks when performing the line search.

##### TRON

- `μ₀::T = T(1e-2)`: algorithm parameter in (0, 0.5);
- `μ₁::T = one(T)`: algorithm parameter in (0, +∞);
- `σ::T = T(10)`: algorithm parameter in (1, +∞);
- `max_cgiter::Int = 50`: subproblem's iteration limit;
- `cgtol::T = T(0.1)`: subproblem tolerance.

##### TRUNK

TODO

##### R2

- `η1 = eps(T)^(1/4)`, `η2 = T(0.95)`: step acceptance parameters;
- `γ1 = T(1/2)`, `γ2 = 1/γ1`: regularization update parameters;
- `σmin = eps(T)`: step parameter for R2 algorithm;
- `β = T(0) ∈ [0,1]` is the constant in the momentum term. If `β == 0`, R2 does not use momentum.

### Constrained

##### Percival

- `μ::Real = T(10.0)`: Starting value of the penalty parameter.

##### CaNNOLeS

- `linsolve::Symbol = :ma57`: solver to compute LDLt factorization. Available methods are: `:ma57`, `:ldlfactorizations`;
- `method::Symbol = :Newton`: available methods `:Newton, :LM, :Newton_noFHess`, and `:Newton_vanishing`;

See [CaNNOLeS.jl tutorial](https://juliasmoothoptimizers.github.io/CaNNOLeS.jl/dev/tutorial/).

##### DCISolver

- `linear_solver = :ldlfact`: Solver for the factorization. options: `:ma57` if `HSL.jl` available.

See [`fine-tuneDCI`](https://juliasmoothoptimizers.github.io/DCISolver.jl/dev/fine-tuneDCI/).

##### RipQP

TODO
