using OptimizationProblems, JSOSuite
# OptimizationProblems is a collection of test problems
# OptimizationProblems has two submodules: PureJuMP and ADNLPProblems (resp. for JuMP and ADNLPModels forumations)
nlp = OptimizationProblems.PureJuMP.kirby2()
stats = minimize(nlp)
