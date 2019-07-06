module JSOSuite

using NLPModels, NLPModelsIpopt

export minimize

function minimize(nlp :: AbstractNLPModel; kwargs...)
  output = ipopt(nlp)
  return output
end

end # module
