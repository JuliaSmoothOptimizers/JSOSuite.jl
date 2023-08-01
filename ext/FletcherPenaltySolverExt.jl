module FletcherPenaltySolverExt

using FletcherPenaltySolver, JSOSuite

function minimize(::Val{:FletcherPenaltySolver}, nlp; kwargs...)
  return FletcherPenaltySolver.fps_solve(nlp; kwargs...)
end

end
