"""
    isnls(nlp::ADNLPModels.AbstractADNLPModel)
    isnls(nlp::MathOptInterface.Nonlinear.Model)
    isnls(nlp::JuMP.Model)
    isnls(nlp::MathOptNLPModel)

Check if the given model has a nonlinear least squares objective.

The function uses the package ExpressionTreeForge to get the expression tree of the objective function,
then try to detect the least squares pattern. There is no guarantee that this function detects it accurately.
"""
function isnls(nlp)
  expr_tree = ExpressionTreeForge.get_expression_tree(nlp)
  F_expr = ExpressionTreeForge.extract_element_functions(expr_tree)
  test_square(expr) = expr.field == ExpressionTreeForge.M_power_operator.Power_operator{Int}(2)
  is_nls = mapreduce(test_square, &, F_expr)::Bool
  return is_nls
end
