function linprog_tests()
  @testset "linprog" begin
    c = [-1.0; -1 / 3]
    Aineq = [1.0 1; 1 1/4; 1 -1; -1/4 -1; -1 -1; -1 1]
    opAineq = LinearOperator(Aineq)
    bupp = [2.0; 1; 2; 1; -1; 2]
    blow = fill(-Inf, length(bupp))
    sol = [2 / 3; 4 / 3]

    output = linprog(c, Aineq, bupp)
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    output = linprog(c, Aineq, blow, bupp)
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    Aeq = [1 1 / 4]
    opAeq = LinearOperator(Aeq)
    beq = [1 / 2]
    sol = [0; 2]

    output = linprog(c, Aineq, bupp, Aeq, beq)
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    lvar = [-1.0; -1 / 2]
    uvar = [3 / 2; 5 / 4]
    sol = [11 / 16; 5 / 4]

    output = linprog(c, Aineq, bupp, lvar, uvar)
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    sol = [3 / 16; 5 / 4]

    output = linprog(c, Aineq, bupp, Aeq, beq, lvar, uvar)
    @test output.dual_feas < 1e-6
    @test output.primal_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    x0 = [1.0; -2.0]

    output = linprog(
      c,
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

linprog_tests()
