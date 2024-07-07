using ADNLPModels, NLPModels, NLPModelsTest, JSOSuite, LinearAlgebra

@info "Test 1"
nlp = BROWNDEN()
JSOSuite.multi_start(nlp; verbose = 1)

# Test 2
d = 5
function f(x; d = d)
  return sum(x[i]^2 / 4000 - prod(cos(x[i] / sqrt(i)) for i in 1:d) + 1 for i in 1:d)
end
T = Float64

@info "Test 2"
nlp = ADNLPModel(f, 300 * ones(T, d), -600 * ones(T, d), 600 * ones(T, d))
ultimate_x = JSOSuite.multi_start(nlp; N = 50, verbose = 10)

norm(grad(nlp, ultimate_x)), obj(nlp, ultimate_x)

@info "Test 3"
nlp = ADNLPModel(f, 300 * ones(T, d))
ultimate_x = JSOSuite.multi_start(
  nlp;
  N = 10,
  verbose = 1,
  solver_verbose = 0,
  multi_solvers = true,
  skip_solvers = ["Percival"],
)

norm(grad(nlp, ultimate_x)), obj(nlp, ultimate_x)
