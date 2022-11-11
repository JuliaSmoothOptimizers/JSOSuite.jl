function runcutest(cutest_problems, solvers; today::String = string(today()))
  return bmark_solvers(
    solvers,
    cutest_problems,
    atol = 1e-6,
    rtol = 1e-6,
    verbose = 0,
    max_time = 60.0,
    max_eval = typemax(Int),
  )
end

nmax = 300
_pnames = CUTEst.select(
  max_var = nmax,
  min_con = 1,
  max_con = nmax,
  only_free_var = true,
  only_equ_con = true,
  objtype = 3:6,
)

#Remove all the problems ending by NE as Ipopt cannot handle them.
pnamesNE = _pnames[findall(x -> occursin(r"NE\b", x), _pnames)]
pnames = setdiff(_pnames, pnamesNE)
cutest_problems = (CUTEstModel(p) for p in pnames)

equality_constrained_solvers = JSOSuite.solvers[JSOSuite.solvers.is_available .&& JSOSuite.solvers.can_solve_nlp .&& JSOSuite.solvers.equalities .&& JSOSuite.solvers.nonlinear_obj, :name]

SUITE[:cutest_300_equality_benchmark] = @benchmarkable runcutest(cutest_problems, equality_constrained_solvers)
