# export feasible_point

# """
#     stats = feasible_point(nlp::Union{AbstractNLPModel, JuMP.Model}; kwargs...)
#     stats = feasible_point(nlp::Union{AbstractNLPModel, JuMP.Model}, solver_name::Symbol; kwargs...)

# Compute a feasible point of the optimization problem `nlp`. The signature is the same as the function [`minimize`](@ref).

# ## Output

# The value returned is a `GenericExecutionStats`, see `SolverCore.jl`, where the `status`, `solution`, `primal_residual`, `iter` and `time` are filled-in.

# ```jldoctest; output = false
# using ADNLPModels, JSOSuite
# c(x) = [10 * (x[2] - x[1]^2); x[1] - 1]
# b = zeros(2)
# nlp = ADNLPModel(x -> 0.0, [-1.2; 1.0], c, b, b)
# stats = feasible_point(nlp, verbose = 0)
# stats

# # output

# "Execution stats: first-order stationary"
# ```
# """
# function feasible_point end

# function feasible_point(nlp::AbstractNLPModel, args...; kwargs...)
#   nls = FeasibilityFormNLS(FeasibilityResidual(nlp))
#   stats_nls = minimize(nls, args...; kwargs...)
#   stats = GenericExecutionStats(nlp)
#   set_status!(stats, stats_nls.status)
#   set_solution!(stats, stats_nls.solution[1:get_nvar(nlp)])
#   set_primal_residual!(stats, stats_nls.objective)
#   set_iter!(stats, stats_nls.iter)
#   set_time!(stats, stats_nls.elapsed_time)
#   return stats
# end

# function feasible_point(model::JuMP.Model, args...; kwargs...)
#   return feasible_point(MathOptNLPModel(model), args...; kwargs...)
# end
