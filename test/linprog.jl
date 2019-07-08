function linprog_tests()
  @testset "linprog" begin
    c = [-1.; -1/3]
    A = [1. 1; 1 1/4; 1 -1; -1/4 -1; -1 -1; -1 1]
    opA = LinearOperator(A)
    bup = [2.; 1; 2; 1; -1; 2]
    sol = [2/3; 4/3]

    output = linprog(c, A, bup)
    @test output.dual_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    output = linprog(c, opA, bup)
    @test output.dual_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    Aeq = [1 1/4]
    opAeq = LinearOperator(Aeq)
    beq = [1/2]
    sol = [0; 2]

    output = linprog(c, A, bup, Aeq, beq)
    @test output.dual_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    output = linprog(c, opA, bup, opAeq, beq)
    @test output.dual_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    lvar = [-1.; -1/2]
    uvar = [3/2; 5/4]
    sol = [3/16; 5/4]

    output = linprog(c, A, bup, Aeq, beq, uvar, lvar)
    @test output.dual_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    output = linprog(c, opA, bup, opAeq, beq, uvar, lvar)
    @test output.dual_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6

    x0 = [1.; -2.]

    output = linprog(c, opA, bup, opAeq, beq, uvar, lvar, x0 = x0)
    @test output.dual_feas < 1e-6
    @test norm(output.solution - sol) < 1e-6
  end
end

linprog_tests()