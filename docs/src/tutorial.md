# [Tutorial](@id tutorial-section)

In this tutorial, we provide examples of usage of the `minimize` function exported by `JSOSuite.jl`.

There are two important challenges in solving an optimization problem: (i) model the problem, and (ii) solve the problem with an appropriate optimizer.

## Modeling

All these optimizers rely on the `NLPModel API` from [NLPModels.jl](https://github.com/JuliaSmoothOptimizers/NLPModels.jl) for general nonlinear optimization problems of the form

```math
\begin{aligned}
\min \quad & f(x) \\
& c_L \leq c(x) \leq c_U \\
& c_A \leq Ax \leq l_A, \\
& \ell \leq x \leq u.
\end{aligned}
```

The function `minimize` accepts as an argument any model `nlp` subtype of `AbstractNLPModel`.

```julia
output = minimize(nlpmodel::AbstractNLPModel; kwargs...)
```

In the rest of this section, we focus on examples using generic modeling tools.

It is generally of great interest if available to use a modeling that exploits the structure of the problem, see [Nonlinear Least Squares](@ref nls-section) for an example with nonlinear least squares.

### JuMP Model

```@example
using JuMP, JSOSuite
model = Model()
@variable(model, x)
@variable(model, y)
@NLobjective(model, Min, (1 - x)^2 + 100 * (y - x^2)^2)

minimize(model)
```

We refer to [`JuMP tutorial`](https://jump.dev/JuMP.jl/stable/) for more on modeling problems with JuMP.

### NLPModel with Automatic Differentiation

We refer to [`ADNLPModel`](https://jso.dev/ADNLPModels.jl/dev/reference/#ADNLPModels.ADNLPModel-Union{Tuple{S},%20Tuple{Any,%20S}}%20where%20S) for the description of the different constructors.

#### Unconstrained

```@example
using JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
stats = minimize(f, x0, verbose = 0)
```

```@example
using ADNLPModels, JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
nlp = ADNLPModel(f, x0)
stats = minimize(nlp)
```

One of the main advantages of this constructor is the possibility to run computations in different arithmetics.

```@example
using JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = Float32[-1.2; 1.0]
stats = minimize(f, x0, verbose = 0)
```

#### Bound-constrained

```@example
using JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
lvar, uvar = 2 * ones(2), 4 * ones(2)
stats = minimize(f, x0, lvar, uvar, verbose = 0)
```

```@example
using ADNLPModels, JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
nlp = ADNLPModel(f, x0)
stats = minimize(nlp)
```

#### Nonlinear constrained

```@example
using JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
c = x -> [x[1]]
l = ones(1)
stats = minimize(f, x0, c, l, l, verbose = 0)
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
stats = minimize(f, x0, A, l, l, verbose = 0)
```

#### All constraints

```@example
using JSOSuite, SparseArrays
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
A = sparse([2.0 3.0])
c = x -> [x[1]]
l = ones(2)
stats = minimize(f, x0, A, c, l, l, verbose = 0)
```

## Optimizing

Internally, the `minimize` function selects optimizers according to the problem's property and their availability.

### Available optimizers

All the information used by the handled optimizers is available in the following `DataFrame`:

```@example ex1
using JSOSuite
JSOSuite.optimizers
```

Required information can be extracted by simple `DataFrame` manipulations. For instance, the list of optimizers handled by this package

```@example ex1
JSOSuite.optimizers.name
```

### Select optimizers

The function [`JSOSuite.select_optimizers`](@ref) returns a list of compatible optimizers.

```@example
using ADNLPModels, JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
nlp = ADNLPModel(f, x0)
JSOSuite.select_optimizers(nlp)
```

### Fine-tune solve call

All the keyword arguments are passed to the solver.
Keywords available for all the solvers are given below:

- `atol::T = √eps(T)`: absolute tolerance;
- `rtol::T = √eps(T)`: relative tolerance;
- `max_time::Float64 = 300.0`: maximum number of seconds;
- `max_iter::Int = typemax(Int)`: maximum number of iterations;
- `max_eval::Int = 10 000`: maximum number of constraint and objective functions evaluations;
- `callback = (args...) -> nothing`: callback called at each iteration;
- `verbose::Int = 0`: if > 0, display iteration details for every `verbose` iteration.

```@example
using ADNLPModels, JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
nlp = ADNLPModel(f, x0)
stats = minimize(nlp, atol = 1e-5, rtol = 1e-7, max_time = 10.0, max_eval = 10000, verbose = 1)
```

Further possible options are documented in each solver's documentation. For instance, we can update the `mem` parameter of `LBFGS`.

```@example
using ADNLPModels, JSOSuite
f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
nlp = ADNLPModel(f, x0)
stats = minimize("LBFGS", nlp, mem = 10, verbose = 1)
```
