# [Nonlinear Least Squares](@id nls-section)

The nonlinear least squares (NLS) optimization problem is a specific case where the objective function is a sum of squares.

```math
\begin{aligned}
\min \quad & f(x):=\tfrac{1}{2}\|F(x)\|^2_2 \\
& c_L \leq c(x) \leq c_U \\
& c_A \leq Ax \leq l_A, \\
& \ell \leq x \leq u.
\end{aligned}
```

Although the problem can be solved using only  ``f``, knowing  ``F`` independently allows the development of more efficient methods.

## Model and solve NLS

In this tutorial, we consider the following equality-constrained problem

```math
\begin{aligned}
\min \quad & f(x):=\tfrac{1}{2}(10 * (x[2] - x[1]^2))^2 + \tfrac{1}{2}(x[1] - 1)^2 \\
& 1 \leq x[1] * x[2] \leq 1,
\end{aligned}
```

where ``1 \leq x[1] x[2] \leq 1`` implies that ``x[1] x[2] = 1``.

In the rest of this tutorial, we will see two ways to model this problem exploiting the knowledge of the structure of the problem.

### NLS using automatic differentiation

Using the package [ADNLPModels.jl](https://github.com/JuliaSmoothOptimizers/ADNLPModels.jl), the problem can be model as an `ADNLSModel` which will use automatic-differentiation to compute the derivatives.

```@example ex1
using ADNLPModels, JSOSuite
F = x -> [10 * (x[2] - x[1]^2); x[1] - 1]
nres = 2 # size of F(x)
x0 = [-1.2; 1.0]
c = x -> [x[1] * x[2]]
l = [1.]
nls = ADNLSModel(F, x0, nres, c, l, l, name="AD-Rosenbrock")
```

Note that the length of the residual function is given explictly to avoid any superfluous evaluation of this (potentially very large) function.

```@example ex1
stats = minimize(nls)
```

`JSOSuite.jl` uses by default automatic differentiation, so the following code would be equivalent:

```@example ex1
stats = minimize(F, x0, nres, c, l, l)
```

By default, `JSOSuite.minimize` will use a solver tailored for nonlineat least squares problem.
Nevertheless, it is also possible to specify the solver to be used.

```@example ex1
using NLPModelsIpopt
stats = minimize("IPOPT", F, x0, nres, c, l, l)
```

We refer to the documentation of [`ADNLPModels.jl`](https://jso.dev/ADNLPModels.jl/dev/backend/) for more details on the AD system use and how to modify it.

### NLS using JuMP

The package [NLPModelsJuMP.jl](https://github.com/JuliaSmoothOptimizers/NLPModelsJuMP.jl) exports a constructor, [`MathOptNLSModel`](https://jso.dev/NLPModelsJuMP.jl/dev/tutorial/#NLPModelsJuMP.MathOptNLSModel), to build an `AbstractNLSModel` using `JuMP`.

```@example
using JuMP, JSOSuite, NLPModelsJuMP

model = Model()
x0 = [-1.2; 1.0]
@variable(model, x[i=1:2], start=x0[i])
@NLexpression(model, F1, x[1] - 1)
@NLexpression(model, F2, 10 * (x[2] - x[1]^2))
@NLconstraint(model, x[1] * x[2] == 1)

nls = MathOptNLSModel(model, [F1, F2], name="Ju-Rosenbrock")
stats = minimize(nls)
```

### JSOSuite automatic detection

The package can be used to try detecting NLS-pattern in a model.

```@example autodetection
using ADNLPModels, JSOSuite
f(x) = (x[2] - x[1]^3)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
nlp = ADNLPModel(f, x0)
stats_nlp = minimize(nlp)
```

The function [`isnls`](@ref) requires the package [ExpressionTreeForge.jl](https://github.com/JuliaSmoothOptimizers/ExpressionTreeForge.jl).
In this example, it detects that the objective function is a nonlinear least squares.

```@example autodetection
using ExpressionTreeForge
JSOSuite.isnls(nlp)
```

Therefore, defining an `ADNLSModel` might improve the solver's behavior.

```@example autodetection
F(x) = [x[2] - x[1]^3, x[1] - 1]
x0 = [-1.2; 1.0]
nls = ADNLSModel(F, x0, 2)
stats_nls = minimize(nls)
```

```@example autodetection
using NLPModels
(neval_obj(nlp), neval_obj(nls))
```

## Find a feasible point of an optimization problem or solve a nonlinear system

We show here how to find the feasible point of a given model.

```math
\begin{aligned}
\min \quad & \tfrac{1}{2}\|s\|^2_2 \\
& 0 \leq s - c(x) \leq 0
& \ell \leq x \leq u.
\end{aligned}
```

This formulation can also be used to solve a set of nonlinear equations.
Finding a feasible point of an optimization problem is useful to determine whether the problem is feasible or not.
Moreover, it is a good practice to find an initial guess.

```@example feas
using ADNLPModels, JSOSuite

f = x -> sum(x.^2)
x0 = ones(3)
c = x -> [x[1]]
b = zeros(1)
nlp = ADNLPModel(f, x0, c, b, b)
stats = feasible_point(nlp)
```

Using the function `cons` from the `NLPModel API`, we can verify that the obtained solution is feasible.

```@example feas
using NLPModels

cons(nlp, stats.solution) # is close to zero.
```
