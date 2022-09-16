function solve(nlp::AbstractNLPModel; verbose = true, highest_derivative_available::Integer = 2, kwargs...)
  select = select_solvers(nlp, verbose, highest_derivative_available)
  select = select[select.can_solve_nlp, :]
  (verbose ≥ 1) && println("Solve using $(first(select).name):")
  solver = first(select)
  return solve(nlp, Val(Symbol(solver.name)); kwargs...)
end

function solve(nlp::AbstractNLSModel; verbose = true, highest_derivative_available::Integer = 2, kwargs...)
  select = select_solvers(nlp, verbose, highest_derivative_available)
  nls_select = select[select.specialized_nls, :]
  solver = if !isempty(nls_select)
    return first(nls_select)
  else
    return first(select)
  end
  (verbose ≥ 1) && println("Solve using $(solver.name):")
  return solve(nlp, Val(Symbol(solver.name)); kwargs...)
end

function solve(nlp, solver_name::String; kwargs...)
  solver = solvers[solvers.name .== solver_name, :]
  if isempty(solver)
    @warn "$(solver_name) does not exist."
    return nothing
  end
  return solve(nlp, Val(Symbol(solver_name)); kwargs...)
end

function solve(nlp, ::Val{solver_name}; kwargs...) where {solver_name}
  solver = solvers[solvers.name .== string(solver_name), :]
  return eval(solver.solve_function[1])(nlp; kwargs...)
end

# See https://www.artelys.com/docs/knitro/3_referenceManual/userOptions.html for the list of options accepted.
function solve(nlp, ::Val{:KNITRO}; kwargs...)
  keywords = Dict(kwargs)
  if :verbose in keys(keywords)
    keywords[:outlev] = keywords[:verbose]
    delete!(keywords, :verbose)
  end
  if :atol in keys(keywords)
    keywords[:opttol_abs] = keywords[:atol]
    keywords[:feastol_abs] = keywords[:atol]
    delete!(keywords, :atol)
  end
  if :rtol in keys(keywords)
    keywords[:opttol] = keywords[:rtol]
    keywords[:feastol] = keywords[:rtol]
    delete!(keywords, :rtol)
  end
  if :max_time in keys(keywords)
    keywords[:maxtime_real] = keywords[:max_time]
    delete!(keywords, :max_time)
  end
  if :max_eval in keys(keywords)
    keywords[:maxfevals] = keywords[:max_eval]
    delete!(keywords, :max_eval)
  end
  return knitro(nlp; keywords...)
end

function solve(nlp, ::Val{:CaNNOLeS}; kwargs...)
  keywords = Dict(kwargs)
  if :verbose in keys(keywords)
    @warn "Not implemented option `verbose` for CaNNOLeS."
    delete!(keywords, :verbose)
  end
  if :atol in keys(keywords)
    @warn "Not implemented option `atol` for CaNNOLeS."
    delete!(keywords, :atol)
  end
  if :rtol in keys(keywords)
    keywords[:ϵtol] = keywords[:rtol]
    keywords[:feastol] = keywords[:rtol]
    delete!(keywords, :rtol)
  end
  if :max_eval in keys(keywords)
    keywords[:max_f] = keywords[:max_eval]
    delete!(keywords, :max_eval)
  end
  return cannoles(nlp; keywords...)
end

function solve(nlp, ::Val{:Percival}; kwargs...)
  keywords = Dict(kwargs)
  if :verbose in keys(keywords)
    @warn "Not implemented option `verbose` for Percival."
    delete!(keywords, :verbose)
  end
  return percival(nlp; keywords...)
end

# Selection of possible [options](https://coin-or.github.io/Ipopt/OPTIONS.html#OPTIONS_REF).
function solve(nlp, ::Val{:IPOPT}; kwargs...)
  keywords = Dict(kwargs)
  if :verbose in keys(keywords)
    keywords[:print_level] = keywords[:verbose]
    delete!(keywords, :verbose)
  end
  if :atol in keys(keywords)
    @warn "Not implemented option `atol` for IPOPT."
    delete!(keywords, :atol)
  end
  if :rtol in keys(keywords)
    keywords[:tol] = keywords[:rtol]
    delete!(keywords, :rtol)
  end
  if :max_time in keys(keywords)
    keywords[:max_cpu_time] = keywords[:max_time]
    delete!(keywords, :max_time)
  end
  if :max_eval in keys(keywords)
    @warn "Not implemented option `max_eval` for IPOPT."
    delete!(keywords, :max_eval)
  end
  return ipopt(nlp; keywords...)
end

function solve(nlp::Union{QuadraticModel{T0}, LLSModel{T0}}, ::Val{:RipQP}; kwargs...) where {T0}
  keywords = Dict(kwargs)
  if :verbose in keys(keywords)
    keywords[:display] = convert(Bool, keywords[:verbose])
    delete!(keywords, :verbose)
  end
  itol = if (:atol in keys(keywords)) && (:rtol in keys(keywords))
    ϵ_pdd = T0(keywords[:rtol])
    ϵ_rb = ϵ_rc = T0(keywords[:atol])
    delete!(keywords, :atol)
    delete!(keywords, :rtol)
    RipQP.InputTol(T0, ϵ_pdd = ϵ_pdd, ϵ_rb = ϵ_rb, ϵ_rc = ϵ_rc)
  elseif :atol in keys(keywords)
    ϵ_pdd = T0(keywords[:rtol])
    ϵ_rb = ϵ_rc = T0(keywords[:atol])
    delete!(keywords, :atol)
    RipQP.InputTol(T0, ϵ_pdd = ϵ_pdd, ϵ_rb = ϵ_rb, ϵ_rc = ϵ_rc)
  elseif :rtol in keys(keywords)
    ϵ_pdd = T0(keywords[:rtol])
    ϵ_rb = ϵ_rc = T0(keywords[:atol])
    delete!(keywords, :rtol)
    RipQP.InputTol(T0, ϵ_pdd = ϵ_pdd, ϵ_rb = ϵ_rb, ϵ_rc = ϵ_rc)
  else
    RipQP.InputTol(T0)
  end
  if :max_time in keys(keywords)
    @warn "Not implemented option `max_time` for RipQP."
    delete!(keywords, :max_time)
  end
  if :max_eval in keys(keywords)
    @warn "Not implemented option `max_eval` for RipQP"
    delete!(keywords, :max_eval)
  end
  return ripqp(nlp; itol = itol, keywords...)
end
