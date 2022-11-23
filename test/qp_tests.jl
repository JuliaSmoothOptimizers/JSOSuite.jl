@testset "Solve quadratic models" begin
  @testset "unconstrained" begin
    c = [3.0; -2.0]
    Hrows = [1, 2, 2]
    Hcols = [1, 1, 2]
    Hvals = [8.0; -1.0; 10.0]
    H = sparse(Hrows, Hcols, Hvals)
    c0 = 1.0
    x0 = [-1.2; 1.0]
    qp_model = QuadraticModel(c, H, c0 = c0, x0 = x0, name = "uncqp_QP")
    stats = solve(qp_model)
    @test true
    solve(c, H, c0 = c0, x0 = x0, name = "uncqp_QP")
    @test true
    solve("RipQP", c, H, c0 = c0, x0 = x0, name = "uncqp_QP")
    @test true
  end

  @testset "bound-constrained" begin
    c = [1.0; 1.0]
    H = sparse([-2.0 0.0; 3.0 4.0])
    uvar = [1.0; 1.0]
    lvar = [0.0; 0.0]
    x0 = [0.5; 0.5]
    qp_model = QuadraticModel(c, H, lvar, uvar, x0 = x0, name = "bndqp_QP")
    stats = solve(qp_model)
    @test true
    solve(c, H, lvar, uvar, x0 = x0, name = "bndqp_QP")
    @test true
    solve("RipQP", c, H, lvar, uvar, x0 = x0, name = "bndqp_QP")
    @test true
  end

  @testset "equality-constrained" begin
    n = 50
    c = zeros(n)
    H = spdiagm(0 => 1.0:n)
    H[n, 1] = 1.0
    A = ones(1, n)
    lcon = [1.0]
    ucon = [1.0]
    qp_model = QuadraticModel(c, H, A, lcon, ucon, name = "eqconqp_QP")
    stats = solve(qp_model)
    @test true
    solve(c, H, A, lcon, ucon, name = "eqconqp_QP")
    @test true
    solve("RipQP", c, H, A, lcon, ucon, name = "eqconqp_QP")
    @test true
  end

  @testset "inequality-constrained" begin
    c = -ones(2)
    Hrows = [1, 2]
    Hcols = [1, 2]
    Hvals = ones(2)
    H = SparseMatrixCOO(2, 2, Hrows, Hcols, Hvals)
    Arows = [1, 1, 2, 2, 3, 3]
    Acols = [1, 2, 1, 2, 1, 2]
    Avals = [1.0; -1.0; -1.0; 1.0; 1.0; 1.0]
    A = SparseMatrixCOO(3, 2, Arows, Acols, Avals)
    c0 = 1.0
    lcon = [0.0; -Inf; -1.0]
    ucon = [Inf; 0.0; 1.0]
    x0 = ones(2)
    qp_model = QuadraticModel(c, H, A, lcon, ucon, c0 = c0, x0 = x0, name = "ineqconqp_QP")
    stats = solve(qp_model)
    @test true
    solve(c, H, A, lcon, ucon, c0 = c0, x0 = x0, name = "ineqconqp_QP")
    @test true
    solve("RipQP", c, H, A, lcon, ucon, c0 = c0, x0 = x0, name = "ineqconqp_QP")
    @test true
  end
end
