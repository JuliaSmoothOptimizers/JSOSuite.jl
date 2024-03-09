"""
    select_optimizers(nlp::Union{AbstractNLPModel, JuMP.Model}, verbose = 1, highest_derivative_available::Integer = 2)

Narrow the list of optimizers to solve `nlp` problem using `highest_derivative_available`.

This function checks whether the model has:
  - linear or nonlinear constraints;
  - unconstrained, bound constraints, equality constraints, inequality constraints;
  - nonlinear or quadratic objective.
A linear or quadratic objective is detected if the type of `nlp` is a `QuadraticModel` or an `LLSModel`.
The selection between a general optimization problem and a nonlinear least squares is done in [`minimize`](@ref).

If no optimizers were selected, consider setting `verbose` to `true` to see what went wrong.

## Output

- `selected_optimizers::DataFrame`: A subset of [`optimizers`](@ref) adapted to the problem `nlp`.

See also [`minimize`](@ref).

## Examples

```jldoctest; output = false
using ADNLPModels, JSOSuite
nlp = ADNLPModel(x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0])
selected_optimizers = JSOSuite.select_optimizers(nlp)
print(selected_optimizers[!, :name])

# output

The problem has 2 variables and no constraints.
Algorithm selection:
- unconstrained: ✓;
- nonlinear objective: ✓;
- may use 2-th order derivative.
There are 6 optimizers available:
["LBFGS", "R2", "FOMO", "TRON", "TRUNK", "Percival"].
["LBFGS", "R2", "FOMO", "TRON", "TRUNK", "Percival"]
```

```jldoctest; output = false
using ADNLPModels, JSOSuite
nlp = ADNLSModel(x -> [10 * (x[2] - x[1]^2), (x[1] - 1)], [-1.2; 1.0], 2)
selected_optimizers = JSOSuite.select_optimizers(nlp)
print(selected_optimizers[!, :name])

# output

The problem has 2 variables and no constraints.
Algorithm selection:
- unconstrained: ✓;
- nonlinear objective: ✓;
- may use 2-th order derivative.
There are 8 optimizers available:
["LBFGS", "R2", "FOMO", "TRON", "TRUNK", "TRON-NLS", "TRUNK-NLS", "Percival"].
["LBFGS", "R2", "FOMO", "TRON", "TRUNK", "TRON-NLS", "TRUNK-NLS", "Percival"]
```
"""
function select_optimizers(
  nlp::AbstractNLPModel{T, S},
  verbose = 1,
  highest_derivative_available::Integer = 2,
) where {T, S}
  select = generic(nlp, optimizers)
  if verbose ≥ 1
    used_name = nlp.meta.name == "Generic" ? "The problem" : "The problem $(nlp.meta.name)"
    s = "$(used_name) has $(nlp.meta.nvar) variables and $(nlp.meta.ncon) constraints."
    s = replace(s, " 0" => " no")
    s = replace(s, "1 variables" => "1 variable")
    s = replace(s, "1 constraints" => "1 constraint")
    println(s)
  end
  (verbose ≥ 1) && println("Algorithm selection:")
  if T != Float64
    (verbose ≥ 1) && println("- $T precision: ✓;")
    select = select[.!select.double_precision_only, :]
  end
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

  all_select = copy(select)
  nsolvers_total_before_derivative = nrow(all_select)

  select = select[select.is_available, :]
  nsolvers_before_derivative = nrow(select)

  if nsolvers_before_derivative == 0
    if nsolvers_total_before_derivative == 0
      (verbose ≥ 1) && println(
        "No solvers are available for this type of problem. Consider open an issue to JSOSuite.jl",
      )
    else
      (verbose ≥ 1) && println(
        "No solvers are available for this type of problem. Consider loading more solvers $(all_select[!, :name_pkg])",
      )
    end
  else
    (verbose ≥ 1) && println("- may use $(highest_derivative_available)-th order derivative.")
    all_select = all_select[all_select.highest_derivative .<= highest_derivative_available, :]
    nsolvers_total_after_derivative = nrow(all_select)
    select = select[select.highest_derivative .<= highest_derivative_available, :]
    nsolvers_after_derivative = nrow(select)
    if (nsolvers_after_derivative == 0) && (nsolvers_before_derivative > 0)
      if (nsolvers_total_after_derivative == 0) && (nsolvers_before_derivative > 0)
        (verbose ≥ 1) && println(
          "No optimizers are available. Consider using higher derivatives, there are $(nsolvers_before_derivative) available.",
        )
      elseif (nsolvers_total_after_derivative > 0)
        (verbose ≥ 1) && println(
          "No optimizers are available for this type of problem. Consider loading more optimizers $(all_select[!, :name_pkg])",
        )
      else
        (verbose ≥ 1) && println(
          "No optimizers are available. Consider using higher derivatives, there are $(nsolvers_before_derivative) available.",
        )
      end
    else
      if verbose ≥ 1
        s = "There are $(nrow(select)) optimizers available:"
        println(replace(s, "are 1 optimizers" => "is 1 optimizer"))
        println("$(select[!, :name]).")
      end
    end
  end
  return select
end

function select_optimizers(model::JuMP.Model, args...; kwargs...)
  nlp = MathOptNLPModel(model)
  return select_optimizers(nlp, args...; kwargs...)
end

"""Checker whether optimizers are Generic only"""
function generic end

generic(::AbstractNLSModel, optimizers::DataFrame) = optimizers
generic(::Union{QuadraticModel, LLSModel}, optimizers::DataFrame) =
  optimizers[optimizers.can_solve_nlp, :]
generic(::AbstractNLPModel, optimizers::DataFrame) = optimizers[optimizers.can_solve_nlp, :]
