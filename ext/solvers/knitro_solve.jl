# See https://www.artelys.com/docs/knitro/3_referenceManual/userOptions.html for the list of options accepted.
function minimize(::Val{:KNITRO}, nlp; kwargs...)
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
  return NLPModelsKnitro.knitro(nlp; keywords...)
end
