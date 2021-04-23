function quadprog_tests()
  @testset "quadprog" begin
    Q = [1.0 -1; -1 2]
    g = [-2.0; -6]
    sol = [10.0; 8]

    output = quadprog(Q, g)
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    Aineq = [1.0 1; -1 2; 2 1]
    opAineq = LinearOperator(Aineq)
    bupp = [2.0; 2; 3]
    blow = fill(-Inf, length(bupp))
    sol = [2 / 3; 4 / 3]

    output = quadprog(Q, g, Aineq, bupp)
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    output = quadprog(Q, g, Aineq, blow, bupp)
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    Aeq = [1 1]
    opAeq = LinearOperator(Aeq)
    beq = [0]
    sol = [-2 / 3; 2 / 3]

    output = quadprog(Q, g, Aineq, bupp, Aeq, beq)
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    lvar = [0.0; 0]
    uvar = [1.0; 1]
    sol = [1.0; 1]

    output = quadprog(Q, g, Aineq, bupp, lvar, uvar)
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    sol = [0.0; 0]

    output = quadprog(Q, g, Aineq, bupp, Aeq, beq, lvar, uvar)
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    x0 = [1.0; -2.0]

    output = quadprog(
      Q,
      g,
      Aineq = opAineq,
      blow = blow,
      bupp = bupp,
      Aeq = opAeq,
      beq = beq,
      lvar = lvar,
      uvar = uvar;
      x0 = x0,
      nlp_scaling_method = "none",
    )
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6
  end
end

quadprog_tests()
