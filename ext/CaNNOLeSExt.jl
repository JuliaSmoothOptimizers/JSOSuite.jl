module CaNNOLeSExt

  using CaNNOLeS, JSOSuite

  JSOSuite.optimizers[JSOSuite.optimizers.name .== "CaNNOLeS", :is_available] .= 1

  function minimize(::Val{:CaNNOLeS}, nlp; kwargs...)
    return CaNNOLeS.cannoles(nlp; linsolve = :ldlfactorizations, kwargs...)
  end

end
