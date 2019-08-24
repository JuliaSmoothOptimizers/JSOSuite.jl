mutable struct LinearRegression
  x :: Vector
  y :: Vector
end

function (regr::LinearRegression)(beta)
  r = regr.y .- beta[1] - beta[2] * regr.x
  return dot(r, r) / 2
end

function minimize_tests()
  f(x) = (x[1] - 1)^2 + 100 * (x[2] - x[1]^2)^2
  x₀ = [-1.2; 1.0]

  nlp = ADNLPModel(f, x₀)
  output = minimize(nlp, print_level=0)
  @test norm(output.solution .- 1) < 1e-6
  @test output.dual_feas < 1e-6

  output = minimize(f, x₀, print_level=0)
  @test norm(output.solution .- 1) < 1e-6
  @test output.dual_feas < 1e-6

  output = minimize(f, x₀, fill(0.1, 2), fill(0.5, 2), print_level=0)
  @test norm(output.solution .- [0.5; 0.25]) < 1e-6
  @test output.dual_feas < 1e-6

  output = minimize(f, x₀, fill(1.1, 2), fill(1.9, 2), print_level=0)
  @test norm(output.solution .- [1.1; 1.21]) < 1e-6
  @test output.dual_feas < 1e-6

  x = range(-1, 1, length=100)
  y = 2x .+ 3 + randn(100) * 0.1
  regr = LinearRegression(x, y)
  nlp = ADNLPModel(regr, x₀)
  β = [ones(100) x] \ y

  output = minimize(nlp, print_level=0)
  @test abs(output.objective - norm(y .- β[1] - β[2] * x)^2 / 2) < 1e-12
  @test output.dual_feas < 1e-6
end

minimize_tests()
