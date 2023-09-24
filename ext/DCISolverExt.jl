module DCISolverExt

using DCISolver, JSOSuite

minimize(::Val{:DCISolver}, nlp; kwargs...) = DCISolver.dci(nlp; kwargs...)

end
