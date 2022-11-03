# [Nonlinear Least Squares](@id nls-section)

The nonlinear least squares (NLS) optimization problem is a specific case where the objective function is a sum of squares.

```math
\begin{aligned}
\min \quad & f(x):=\tfrac{1}{2}\|F(x)\|^2_2 \\
& c_L \leq c(x) \leq c_U \\
& c_A \leq Ax \leq l_A, \\
& \ell \leq x \leq u,
\end{aligned}
```

Although the problem can be solved using only  ``f``, knowing  ``F`` independently allows the development of more efficient methods.

## Model and solve NLS

### NLS using automatic differentiation

The package [ADNLPModels.jl](https://github.com/JuliaSmoothOptimizers/ADNLPModels.jl])

```@example
using ADNLPModels, JSOSuite
F = x -> [10 * (x[2] - x[1]^2); x[1] - 1]
nres = 2 # size of F(x)
x0 = [-1.2; 1.0]
nls = ADNLSModel(F, x0, nres, name="AD-Rosenbrock")
stats = solve(nls)
```

### NLS using JuMP

The package [NLPModelsJuMP.jl](https://github.com/JuliaSmoothOptimizers/NLPModelsJuMP.jl) exports a constructor, [`MathOptNLSModel`](https://juliasmoothoptimizers.github.io/NLPModelsJuMP.jl/dev/tutorial/#NLPModelsJuMP.MathOptNLSModel), to build an `AbstractNLSModel` using JuMP.

```@example
using JuMP, JSOSuite, NLPModelsJuMP

model = Model()
x0 = [-1.2; 1.0]
@variable(model, x[i=1:2], start=x0[i])
@NLexpression(model, F1, x[1] - 1)
@NLexpression(model, F2, 10 * (x[2] - x[1]^2))

nls = MathOptNLSModel(model, [F1, F2], name="Ju-Rosenbrock")
stats = solve(nls)
```

## Find a feasible point of an optimization problem

We show here how to find the feasible point of a given model. 
This is a particularly good practice to find an initial guess.

```@example feas
using ADNLPModels, JSOSuite

f = x -> sum(x.^2)
x0 = ones(3)
c = x -> [x[1]]
b = zeros(1)
nlp = ADNLPModel(f, x0, c, b, b)
stats = feasible(nlp)
```

Using the function `cons` from the NLPModel API, we can verify that the obtained solution is feasible.

```@example feas
using NLPModels

cons(nlp, stats.solution) # is close to zero.
```
