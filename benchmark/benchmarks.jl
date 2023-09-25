using BenchmarkTools, ADNLPModels
using JSOSuite

# Run locally with `tune!(SUITE)` and then `run(SUITE)`
const SUITE = BenchmarkGroup()

SUITE["solvers"] = BenchmarkGroup(["solver"])

nlp = ADNLPModel(x -> (x[1] - 1)^2 + 4 * (x[2] - x[1]^2)^2, [-1.2; 1.0])
for solver in eachrow(JSOSuite.select_optimizers(nlp))
  SUITE["solvers"][solver.name] = @benchmarkable begin
    minimize($(solver.name), $nlp)
  end
end
