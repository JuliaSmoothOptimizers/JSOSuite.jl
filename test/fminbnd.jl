function fminbnd_tests()
  @testset "fminbnd" begin
    f(x) = (x[1] - 1)^2 + 100 * (x[2] - x[1]^2)^2
    x₀ = [-1.2; 1.0]
    ℓ, u = zeros(2), fill(0.5, 2)

    output = fminbnd(f, x₀, ℓ, u)
    @test norm(output.solution .- [0.5; 0.25]) < 1e-6
    @test output.dual_feas < 1e-6

    output = fminbnd(f, x₀, ℓ, u; solver = :tron, max_eval = Int(1e6))
    @test norm(output.solution .- [0.5; 0.25]) < 1e-6
    @test output.dual_feas < 1e-6

    output = fminbnd(f, x₀, ℓ, u, atol=1e-12, rtol=1e-12)
    @test norm(output.solution .- [0.5; 0.25]) < 1e-10
    @test output.dual_feas < 1e-9

    output = fminbnd(f, x₀, ℓ, u, max_eval=2)
    @test output.status == :max_eval

    output = fminbnd(f, x₀, -ones(2), ones(2), max_time=0.0001)
    @test output.status == :max_time
  end
end

fminbnd_tests()
