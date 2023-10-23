@testset "Basic usage" begin
  f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
  x₀ = [-1.2; 1.0]
  output = minimize(f, x₀, verbose = 0)
  @test output.status == :first_order

  ℓ, u = zeros(2), ones(2)
  output = minimize(f, x₀, ℓ, u)
  @test output.status == :first_order

  c = x -> [x[1] + x[2]]
  output = minimize(f, x₀, c, [0.0], [0.0])
  @test output.status == :first_order

  output = minimize(f, x₀, ℓ, u, c, [0.0], [0.0])
  @test output.status == :first_order
end

@testset "Basic usage with explicit solver" begin
  @testset "solver $Solver" for Solver in JSOSuite._optimizers
    f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
    x₀ = [-1.2; 1.0]
    output = minimize(Solver, f, x₀, verbose = 0)
    @test output.status == :first_order
    output = minimize(Solver(), f, x₀, verbose = 0)
    @test output.status == :first_order
  end
end

@testset "Test keyword arguments" begin
  @testset "solver $Solver" for Solver in JSOSuite._optimizers
    f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
    x₀ = [-1.2; 1.0]
    cb = (args...) -> nothing
    output = minimize(
      Solver,
      f,
      x₀,
      verbose = 0,
      atol = 1e-5,
      rtol = 1e-5,
      max_time = 60.0,
      max_iter = 100,
      max_eval = 100,
      callback = cb,
    )
    @test output.status == :first_order
  end
end
