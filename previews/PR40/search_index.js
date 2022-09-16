var documenterSearchIndex = {"docs":
[{"location":"reference/#Reference","page":"Reference","title":"Reference","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/#Contents","page":"Reference","title":"Contents","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Pages = [\"reference.md\"]","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/#Index","page":"Reference","title":"Index","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Pages = [\"reference.md\"]","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Modules = [JSOSuite]","category":"page"},{"location":"reference/#JSOSuite.solve","page":"Reference","title":"JSOSuite.solve","text":"stats = solve(nlp::AbstractNLPModel; kwargs...)\nstats = solve(nlp::AbstractNLPModel, solver_name::Symbol; kwargs...)\n\nCompute a local minimum of the optimization problem nlp.\n\nKeyword Arguments\n\nAll the keyword arguments are passed to the selected solver. Keywords available for all the solvers are given below:\n\natol: absolute tolerance;\nrtol: relative tolerance;\nmax_time: maximum number of seconds;\nmax_eval: maximum number of cons + obj evaluations;\nverbose::Int = 0: if > 0, display iteration details every verbose iteration.\n\nFurther possible options are documented in each solver's documentation.\n\nExamples\n\nusing ADNLPModels, JSOSuite\nnlp = ADNLPModel(x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0])\nstats = solve(nlp, verbose = false)\nstats\n\n\n\n\n\n","category":"function"},{"location":"#JSOSuite.jl","page":"Home","title":"JSOSuite.jl","text":"","category":"section"},{"location":"tutorial/#JSOSuite.jl-Tutorial","page":"Tutorial","title":"JSOSuite.jl Tutorial","text":"","category":"section"}]
}