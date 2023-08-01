module DCISolverExt

using DCISolver, JSOSuite

JSOSuite.optimizers[JSOSuite.optimizers.name .== "DCISolver", :is_available] .= 1
    function minimize(::Val{:DCISolver}, nlp; kwargs...)
      return DCISolver.dci(nlp; kwargs...)
    end

end
