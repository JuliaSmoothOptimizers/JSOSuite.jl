function linprog_tests()
  c = [-1.; -1/3]
  A = [1. 1; 1 1/4; 1 -1; -1/4 -1; -1 -1; -1 1]
  b = [2.; 1; 2; 1; -1; 2]
  sol = [2/3; 4/3]
  output = linprog(c, A, b)
  @test output.dual_feas < 1e-6
  @test norm(output.solution - sol) < 1e-6

  opA = LinearOperator(A)
  output = linprog(c, opA, b)
  @test output.dual_feas < 1e-6
  @test norm(output.solution - sol) < 1e-6
end

linprog_tests()
