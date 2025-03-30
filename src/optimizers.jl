"""
    optimizers

DataFrame with the JSO-compliant solvers and their properties.

For each solver, the following are available:
- `name::String`: name of the solver;
- `name_solver::Symbol`: name of the solver structure for in-place solve, `:not_implemented` if not implemented;
- `name_parameters::Symbol`: name of the parameter structure, `:not_implemented` if not implemented;
- `name_pkg::String`: name of the package implementing this solver or its NLPModel wrapper;
- `solve_function::Symbol`: name of the function;
- `is_available::Bool`: `true` if the solver is available;
- `bounds::Bool`: `true` if the solver can handle bound constraints;
- `equalities::Bool`: `true` if the solver can handle equality constraints;
- `inequalities::Bool`: `true` if the solver can handle inequality constraints;
- `specialized_nls::Bool`: `true` if the solver has a specialized variant for nonlinear least squares;
- `can_solve_nlp::Bool`: `true` if the solver can solve general problems. Some may only solve nonlinear least squares;
- `nonlinear_obj::Bool`: `true` if the solver can handle nonlinear objective;
- `nonlinear_con::Bool`: `true` if the solver can handle nonlinear constraints;
- `double_precision_only::Bool`: `true` if the solver only handles double precision (`Float64`);
- `highest_derivative::Int`: order of the highest derivative used by the algorithm.
"""
optimizers = DataFrame(;
  name = String[],
  name_solver = Symbol[],
  name_parameters = Symbol[],
  name_pkg = String[],
  solve_function = Symbol[],
  is_available = Bool[],
  bounds = Bool[],
  equalities = Bool[],
  inequalities = Bool[],
  specialized_nls = Bool[],
  can_solve_nlp = Bool[],
  nonlinear_obj = Bool[],
  nonlinear_con = Bool[],
  double_precision_only = Bool[],
  highest_derivative = Int[],
)

push!(
  optimizers,
  (
    "KNITRO",
    :KnitroSolver,
    :not_implemented,
    "NLPModelsKnitro.jl",
    :knitro,
    false,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    2,
  ),
)
push!(
  optimizers,
  (
    "LBFGS",
    :LBFGSSolver,
    :LBFGSParameterSet,
    "JSOSolvers.jl",
    :lbfgs,
    true,
    false,
    false,
    false,
    false,
    true,
    true,
    true,
    false,
    1,
  ),
)
push!(
  optimizers,
  (
    "R2",
    :R2Solver,
    :FOMOParameterSet,
    "JSOSolvers.jl",
    :R2,
    true,
    false,
    false,
    false,
    false,
    true,
    true,
    true,
    false,
    1,
  ),
)
push!(
  optimizers,
  (
    "TRON",
    :TronSolver,
    :TRONParameterSet,
    "JSOSolvers.jl",
    :tron,
    true,
    true,
    false,
    false,
    false,
    true,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "TRUNK",
    :TrunkSolver,
    :TRUNKParameterSet,
    "JSOSolvers.jl",
    :trunk,
    true,
    false,
    false,
    false,
    false,
    true,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "TRON-NLS",
    :TronSolverNLS,
    :TRONLSParameterSet,
    "JSOSolvers.jl",
    :tron,
    true,
    true,
    false,
    false,
    true,
    false,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "TRUNK-NLS",
    :TrunkSolverNLS,
    :TRUNKLSParameterSet,
    "JSOSolvers.jl",
    :trunk,
    true,
    false,
    false,
    false,
    true,
    false,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "CaNNOLeS",
    :CaNNOLeSSolver,
    :not_implemented,
    "CaNNOLeS.jl",
    :cannoles,
    false,
    false,
    true,
    false,
    true,
    false,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "IPOPT",
    :IpoptSolver,
    :not_implemented,
    "NLPModelsIpopt.jl",
    :ipopt,
    false,
    true,
    true,
    true,
    false,
    true,
    true,
    true,
    true,
    2,
  ),
)
push!(
  optimizers,
  (
    "DCISolver",
    :DCIWorkspace,
    :not_implemented,
    "DCISolver.jl",
    :dci,
    false,
    false,
    true,
    false,
    false,
    true,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "FletcherPenaltySolver",
    :FPSSSolver,
    :not_implemented,
    "FletcherPenaltySolver.jl",
    :fps_solve,
    false,
    false,
    true,
    false,
    false,
    true,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "Percival",
    :PercivalSolver,
    :not_implemented,
    "Percival.jl",
    :percival,
    true,
    true,
    true,
    true,
    false,
    true,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "RipQP",
    :RipQPSolver,
    :not_implemented,
    "RipQP.jl",
    :ripqp,
    false,
    true,
    true,
    true,
    false,
    false,
    false,
    false,
    false,
    2,
  ),
) # need to check linear constraints and quadratic constraints
