# Selection of possible [options](https://coin-or.github.io/Ipopt/OPTIONS.html#OPTIONS_REF).
function minimize(::Val{:IPOPT}, nlp; kwargs...)
  keywords = Dict(kwargs)
  if :verbose in keys(keywords)
    if keywords[:verbose] == 0
      keywords[:print_level] = keywords[:verbose]
    end
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
    max_time = keywords[:max_time]
    if max_time > 0
      keywords[:max_cpu_time] = max_time
    else
      @warn "`max_time` should be positive, ignored parameter."
    end
    delete!(keywords, :max_time)
  end
  if :max_eval in keys(keywords)
    @warn "Not implemented option `max_eval` for IPOPT."
    delete!(keywords, :max_eval)
  end
  if :callback in keys(keywords)
    @warn "Not implemented option `callback` for IPOPT."
    delete!(keywords, :callback)
  end
  return NLPModelsIpopt.ipopt(nlp; keywords...)
end
