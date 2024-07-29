#using ExpressionTreeForge
#using ..ExpressionTreeForge.M_power_operator

"""
    isnlp(nlp::ADNLPModels.AbstractADNLPModel)
    isnlp(nlp::MathOptInterface.Nonlinear.Model)
    isnlp(nlp::JuMP.Model)
    isnlp(nlp::MathOptNLPModel)

Check if the given model has a nonlinear least squares objective.

The function uses the package ExpressionTreeForge to get the expression tree of the objective function,
then try to detect the least squares pattern. There is no guarantee that this function detects it accurately.
"""
function isnls(nlp)
  expr_tree = ExpressionTreeForge.get_expression_tree(nlp)
  F_expr = extract_element_functions(expr_tree)
  test_square(expr) = expr.field == ExpressionTreeForge.M_power_operator.Power_operator{Int}(2)
  myand(a::Bool,b::Bool) = a && b
  is_nls = mapreduce(test_square, myand, F_expr) :: Bool
  return is_nls 
end 
