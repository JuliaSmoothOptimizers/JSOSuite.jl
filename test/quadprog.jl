function quadprog_tests()
  Q = [1. -1; -1 2]
  g = [-2.; -6]
  A = [1. 1; -1 2; 2 1]
  b = [2.; 2; 3]
  sol = [2/3; 4/3]
  output = quadprog(Q, g, A, b)
  @test output.dual_feas < 1e-6
  @test norm(output.solution - sol) < 1e-6
end

quadprog_tests()
