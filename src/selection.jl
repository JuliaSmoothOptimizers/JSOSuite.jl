"""
    select_solvers(nlp::AbstractNLPModel, verbose = 1, highest_derivative_available::Integer = 2)

Narrow the list of solvers to solve `nlp` problem using `highest_derivative_available`.

This function checks whether the model has:
  - linear or nonlinear constraints;
  - unconstrained, bound constraints, equality constraints, inequality constraints;
  - nonlinear or quadratic objective.
A linear or quadratic objective is detected if the type of `nlp` is a `QuadraticModel` or an `LLSModel`.
The selection between a general optimization problem and a nonlinear least squares is done in [`solve`](@ref).

If no solvers were selected, consider setting `verbose` to `true` to see what went wrong.

## Output

- `selected_solvers::DataFrame`: A subset of [`solvers`](@ref) adapted to the problem `nlp`.

See also [`solve`](@ref).

## Examples

```jldoctest; output = false
using ADNLPModels, JSOSuite
nlp = ADNLPModel(x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0])
selected_solvers = JSOSuite.select_solvers(nlp)
print(selected_solvers[!, :name])

# output

The problem has 2 variables and no constraints.
Algorithm selection:
- unconstrained: ✓;
- nonlinear objective: ✓;
- may use 2-th order derivative.
There are 10 solvers available:
["LBFGS", "R2", "TRON", "TRUNK", "TRON-NLS", "TRUNK-NLS", "CaNNOLeS", "IPOPT", "Percival", "DCISolver"].
["LBFGS", "R2", "TRON", "TRUNK", "TRON-NLS", "TRUNK-NLS", "CaNNOLeS", "IPOPT", "Percival", "DCISolver"]
```
"""
function select_solvers(
  nlp::AbstractNLPModel,
  verbose = 1,
  highest_derivative_available::Integer = 2,
)
  select = solvers[solvers.is_available, :]
  if verbose ≥ 1
    used_name = nlp.meta.name == "Generic" ? "The problem" : "The problem $(nlp.meta.name)"
    s = "$(used_name) has $(nlp.meta.nvar) variables and $(nlp.meta.ncon) constraints."
    s = replace(s, "0" => "no", "1 variables" => "1 variable", "1 constraints" => "1 constraint")
    println(s)
  end
  (verbose ≥ 1) && println("Algorithm selection:")
  if !unconstrained(nlp)
    if has_equalities(nlp)
      (verbose ≥ 1) && println("- equalities: ✓;")
      select = select[select.equalities, :]
    end
    if has_inequalities(nlp)
      (verbose ≥ 1) && println("- inequalities: ✓;")
      select = select[select.inequalities, :]
    end
    if has_bounds(nlp)
      (verbose ≥ 1) && println("- bounds: ✓;")
      select = select[select.inequalities, :]
    end
    if !linearly_constrained(nlp)
      (verbose ≥ 1) && println("- nonlinear constraints: ✓;")
      select = select[select.nonlinear_con, :]
    else
      (verbose ≥ 1) && println("- linear constraints: ✓;")
    end
  else
    (verbose ≥ 1) && println("- unconstrained: ✓;")
  end
  if !(typeof(nlp) <: QuadraticModel) || !(typeof(nlp) <: LLSModel)
    (verbose ≥ 1) && println("- nonlinear objective: ✓;")
    select = select[select.nonlinear_obj, :]
  else
    (verbose ≥ 1) && println("- quadratic objective: ✓;")
  end
  nsolvers_before_derivative = nrow(select)
  if nsolvers_before_derivative == 0
    (verbose ≥ 1) && println(
      "No solvers are available for this type of problem. Consider open an issue to JSOSuite.jl",
    )
  else
    (verbose ≥ 1) && println("- may use $(highest_derivative_available)-th order derivative.")
    select = select[select.highest_derivative .<= highest_derivative_available, :]
    nsolvers_after_derivative = nrow(select)
    if (nsolvers_after_derivative == 0) && (nsolvers_before_derivative > 0)
      (verbose ≥ 1) && println(
        "No solvers are available. Consider using higher derivatives, there are $(nsolvers_before_derivative) available.",
      )
    else
      if verbose ≥ 1
        s = "There are $(nrow(select)) solvers available:"
        println(replace(s, "are 1 solvers" => "is 1 solver"))
        println("$(select[!, :name]).")
      end
    end
  end
  return select
end
