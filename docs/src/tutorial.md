# [Tutorial](@id tutorial-section)

In this tutorial, we provide examples of usage of the `solve` function exported by `JSOSuite.jl`.

There are two important challenges in solving an optimization problem: (i) model the problem, and (ii) solve the problem with an appropriate solver.

## Modeling

All these solvers rely on the `NLPModel API` from [NLPModels.jl](https://github.com/JuliaSmoothOptimizers/NLPModels.jl) for general nonlinear optimization problems of the form

```math
\begin{aligned}
\min \quad & f(x) \\
& c_L \leq c(x) \leq c_U \\
& c_A \leq Ax \leq l_A, \\
& \ell \leq x \leq u,
\end{aligned}
```

The function `solve` accepts as an argument any model `nlp` subtype of `AbstractNLPModel`.
```julia
output = solve(nlpmodel::AbstractNLPModel; kwargs...)
```

In the rest of this section, we focus on examples using generic modeling tools.

It is generally of great interest if available to use a modeling that handles the structure of the problem, see [Nonlinear Least Squares](@ref nls-section) for an example with nonlinear least squares.

### JuMP Model

```@example
using JuMP, JSOSuite
model = Model()
@variable(model, x)
@variable(model, y)
@NLobjective(model, Min, (1 - x)^2 + 100 * (y - x^2)^2)

solve(model)
```

We refer to [`JuMP tutorial`](https://jump.dev/JuMP.jl/stable/).

### NLPModel with Automatic Differentiation

We refer to [`ADNLPModel`](https://juliasmoothoptimizers.github.io/ADNLPModels.jl/dev/reference/#ADNLPModels.ADNLPModel-Union{Tuple{S},%20Tuple{Any,%20S}}%20where%20S) for the description of the different constructors.

#### Unconstrained

```@example
using JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
stats = solve(f, x0, verbose = 0)
```

```@example
using ADNLPModels, JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
nlp = ADNLPModel(f, x0)
stats = solve(nlp)
```

One of the main advantages of this constructor is the possibility to run computations in different arithmetics. 

```@example
using JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = Float32[-1.2; 1.0]
stats = solve(f, x0, verbose = 0)
```

#### Bound-constrained

```@example
using JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
lvar, uvar = 2 * ones(2), 4 * ones(2)
stats = solve(f, x0, lvar, uvar, verbose = 0)
```

```@example
using ADNLPModels, JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
nlp = ADNLPModel(f, x0)
stats = solve(nlp)
```

#### Nonlinear constrained

```@example
using JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
c = x -> [x[1]]
l = ones(1)
stats = solve(f, x0, c, l, l, verbose = 0)
```

#### Linearly constrained

```@example
using JSOSuite, SparseArrays
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
A = sparse([
    1.0 0.0;
    2.0 3.0
])
l = ones(2)
stats = solve(f, x0, A, l, l, verbose = 0)
```

#### All constraints

```@example
using JSOSuite, SparseArrays
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
A = sparse([2.0 3.0])
c = x -> [x[1]]
l = ones(2)
stats = solve(f, x0, A, c, l, l, verbose = 0)
```

## Solving

Internally, the `solve` function selects solvers according to the problem's property and JSO-compliant solvers available.

### Available solvers

All the information used by the handled solvers is available in the following `DataFrame`:

```@example ex1
using JSOSuite
JSOSuite.solvers
```

Required information can be extracted by simple `DataFrame` manipulations. For instance, the list of solvers handled by this package
```@example ex1
JSOSuite.solvers.name
```

### Select solvers

The function [`JSOSuite.select_solvers`](@ref) returns a list of compatible solvers.
```@example
using ADNLPModels, JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
nlp = ADNLPModel(f, x0)
JSOSuite.select_solvers(nlp)
```

### Fine-tune solve call

All the keyword arguments are passed to the solver.
Keywords available for all the solvers are given below:

- `atol`: absolute tolerance;
- `rtol`: relative tolerance;
- `max_time`: maximum number of seconds;
- `max_eval`: maximum number of cons + obj evaluations;
- `verbose::Int = 0`: if > 0, display iteration details every `verbose` iteration.

```@example
using ADNLPModels, JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
nlp = ADNLPModel(f, x0)
stats = solve(nlp, atol = 1e-5, rtol = 1e-7, max_time = 10.0, max_eval = 10000, verbose = 1)
```

Further possible options are documented in each solver's documentation. For instance, we can update the `mem` parameter of `LBFGS`.

```@example
using ADNLPModels, JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
nlp = ADNLPModel(f, x0)
stats = solve("LBFGS", nlp, mem = 10, verbose = 1)
```
