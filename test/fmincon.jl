
function fmincon_tests()
  @testset "fmincon" begin
    f(x) = (x[1] - 1)^2 + 100 * (x[2] - x[1]^2)^2
    x₀ = [-1.2; 1.0]
    c(x) = [x[1]^2 + x[2]^2 - 1]
    tol = 1e-6

    # given x with f(x) == 0, return Δx = [Δx₁; Δx₂] s.t. f(x + Δx) ≈ 0 and f(x - Δx) ≈ 0
    getΔx(x, Δx₁ = 1e-3) = [Δx₁; (1 / 2) * ( - 2 * x[2] + sqrt( 4 * x[2]^2 - 4 * (2 * x[1] * Δx₁ + Δx₁^2) ) )]

    # checks the objective value around a given solution to see if it's a local minima
    function forced_check_min(sol, Δx, tol = 1e-5, f = f, c = c)
      @test c(output.solution + Δx)[1] < tol
      @test f(output.solution) <= f(output.solution + Δx)
      @test c(output.solution - Δx)[1] < tol
      @test f(output.solution) <= f(output.solution - Δx)
    end

    output = fmincon(f, x₀, c, 1)
    @test c(output.solution)[1] < tol
    @test output.dual_feas < tol
    @test output.primal_feas < tol
    forced_check_min(output.solution, getΔx(output.solution))

    output = fmincon(f, x₀, c, 1; solver = :ipopt, nlp_scaling_method="none")
    @test c(output.solution)[1] < tol
    @test output.dual_feas < tol
    @test output.primal_feas < tol
    forced_check_min(output.solution, getΔx(output.solution))

    output = fmincon(f, x₀, c, 1, atol=1e-12, rtol=1e-12)
    @test c(output.solution)[1] < 1e-9 
    @test output.primal_feas < 1e-9
    @test output.dual_feas < 1e-9
    forced_check_min(output.solution, getΔx(output.solution))

    output = fmincon(x -> begin sleep(0.005); f(x) end, x₀, c, 1, max_time=0.001)
    @test output.status == :max_time

    output = fmincon(f, x₀, c, [-1.0], [1.0])
    @test norm(output.solution .- 1) < 1e-4
    @test output.dual_feas < tol
    @test output.primal_feas < tol

    output = fmincon(f, 2 * ones(2), c, 1, x->[x[1] * x[2]], 1)
    @test norm(output.solution .- [0.786415; 0.617698]) < 1e-4
    @test output.dual_feas < tol
    @test output.primal_feas < tol

    output = fmincon(f, x₀, -ones(2), 0.5 * ones(2), c, [-1.0], [1.0])
    @test norm(output.solution .- [0.5; 0.25]) < 1e-4
    @test output.dual_feas < tol
    @test output.primal_feas < tol
  end
end

fmincon_tests()
