module CaNNOLeSExt

  using CaNNOLeS, JSOSuite

  function minimize(::Val{:CaNNOLeS}, nlp; kwargs...)
    return CaNNOLeS.cannoles(nlp; linsolve = :ldlfactorizations, kwargs...)
  end

end
