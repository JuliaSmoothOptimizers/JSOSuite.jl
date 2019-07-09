function linprog_tests()
  @testset "linprog" begin

    c = [-1.; -1/3]
    A = [1. 1; 1 1/4; 1 -1; -1/4 -1; -1 -1; -1 1]
    opA = LinearOperator(A)
    bup = [2.; 1; 2; 1; -1; 2]
    blow = fill(-Inf, length(bup))
    sol = [2/3; 4/3]

    output = linprog(c, A, blow, bup)
    @test output.dual_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    output = linprog(c, opA, blow, bup)
    @test output.dual_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    Aeq = [1 1/4]
    opAeq = LinearOperator(Aeq)
    beq = [1/2]
    sol = [0; 2]

    output = linprog(c, A, blow, bup, Aeq, beq)
    @test output.dual_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    output = linprog(c, opA, blow, bup, opAeq, beq)
    @test output.dual_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    lvar = [-1.; -1/2]
    uvar = [3/2; 5/4]
    sol = [3/16; 5/4]

    output = linprog(c, A, blow, bup, Aeq, beq, lvar, uvar)
    @test output.dual_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    output = linprog(c, opA, blow, bup, opAeq, beq, lvar, uvar)
    @test output.dual_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    x0 = [1.; -2.]

    output = linprog(c, A = A, blow = blow, bup = bup, Aeq = Aeq, beq = beq, lvar = lvar, uvar = uvar, x0 = x0)
    @test output.dual_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6
  end
end

linprog_tests()