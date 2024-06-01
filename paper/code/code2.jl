using NLPModelsTest, Percival, SolverCore
nlp = NLPModelsTest.HS6()
solver = PercivalSolver(nlp)
stats = GenericExecutionStats(nlp)
solve!(solver, nlp, stats)
SolverCore.reset!(solver)
SolverCore.reset!(nlp) # reset function evaluation counters
@allocated solve!(solver, nlp, stats) # = 0
