function fminunc_tests()
  @testset "fminunc" begin
    f(x) = (x[1] - 1)^2 + 100 * (x[2] - x[1]^2)^2
    x₀ = [-1.2; 1.0]

    output = fminunc(f, x₀)
    @test norm(output.solution .- 1) < 1e-6
    @test output.dual_feas < 1e-6

    output = fminunc(f, x₀; solver = :lbfgs, max_eval = Int(1e6))
    @test norm(output.solution .- 1) < 1e-6
    @test output.dual_feas < 1e-6

    output = fminunc(f, x₀, atol=1e-12, rtol=1e-12)
    @test norm(output.solution .- 1) < 1e-10
    @test output.dual_feas < 1e-9

    output = fminunc(f, x₀, max_eval=10)
    @test output.status == :max_eval

    output = fminunc(f, x₀, max_time=0.0001)
    @test output.status == :max_time
  end
end

fminunc_tests()
