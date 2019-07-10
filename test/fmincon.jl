function fmincon_tests()
  @testset "fmincon" begin
    f(x) = (x[1] - 1)^2 + 100 * (x[2] - x[1]^2)^2
    x₀ = [-1.2; 1.0]
    c(x) = [x[1]^2 + x[2]^2 - 1]

    output = fmincon(f, x₀, c, 1)
    @test norm(output.solution .- [-0.783930; 0.620849]) < 1e-6
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6

    output = fmincon(f, x₀, c, 1, atol=1e-12, rtol=1e-12)
    @test norm(output.solution .- [-0.783930186167; 0.6208489858378]) < 1e-10
    @test output.primal_feas < 1e-9
    @test output.dual_feas < 1e-9

    #= ipopt does not have max_eval
    output = fmincon(f, x₀, c, 1, max_eval=2)
    @test output.status == :max_eval
    =#

    output = fmincon(f, x₀, c, 1, max_time=0.001)
    @test output.status == :max_time

    output = fmincon(f, x₀, c, [-1.0], [1.0])
    @test norm(output.solution .- 1) < 1e-4
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6

    output = fmincon(f, 2 * ones(2), c, 1, x->[x[1] * x[2]], 1)
    @test norm(output.solution .- [0.786415; 0.617698]) < 1e-4
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6

    output = fmincon(f, x₀, -ones(2), 0.5 * ones(2), c, [-1.0], [1.0])
    @test norm(output.solution .- [0.5; 0.25]) < 1e-4
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6
  end
end

fmincon_tests()
