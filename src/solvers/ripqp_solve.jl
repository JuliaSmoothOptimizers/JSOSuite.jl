function solve(
  ::Val{:RipQP},
  nlp::Union{QuadraticModel{T0}, LLSModel{T0}};
  max_iter = 200,
  max_time = 1200.0,
  kwargs...,
) where {T0}
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
    RipQP.InputTol(
      T0,
      ϵ_pdd = ϵ_pdd,
      ϵ_rb = ϵ_rb,
      ϵ_rc = ϵ_rc,
      max_iter = max_iter,
      max_time = max_time,
    )
  elseif :atol in keys(keywords)
    ϵ_pdd = T0(keywords[:rtol])
    ϵ_rb = ϵ_rc = T0(keywords[:atol])
    delete!(keywords, :atol)
    RipQP.InputTol(
      T0,
      ϵ_pdd = ϵ_pdd,
      ϵ_rb = ϵ_rb,
      ϵ_rc = ϵ_rc,
      max_iter = max_iter,
      max_time = max_time,
    )
  elseif :rtol in keys(keywords)
    ϵ_pdd = T0(keywords[:rtol])
    ϵ_rb = ϵ_rc = T0(keywords[:atol])
    delete!(keywords, :rtol)
    RipQP.InputTol(
      T0,
      ϵ_pdd = ϵ_pdd,
      ϵ_rb = ϵ_rb,
      ϵ_rc = ϵ_rc,
      max_iter = max_iter,
      max_time = max_time,
    )
  else
    RipQP.InputTol(T0)
  end
  if :max_eval in keys(keywords)
    @warn "Not implemented option `max_eval` for RipQP."
    delete!(keywords, :max_eval)
  end
  if :callback in keys(keywords)
    @warn "Not implemented option `callback` for RipQP."
    delete!(keywords, :callback)
  end
  return RipQP.ripqp(nlp; itol = itol, keywords...)
end
