module FletcherPenaltySolverExt

using FletcherPenaltySolver, JSOSuite
JSOSuite.optimizers[JSOSuite.optimizers.name .== "FletcherPenaltySolver", :is_available] .= 1
    function minimize(::Val{:FletcherPenaltySolver}, nlp; kwargs...)
      return FletcherPenaltySolver.fps_solve(nlp; kwargs...)
    end
end
