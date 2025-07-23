problems_names = OptimizationProblems.meta[!, :name][1:50] # we test only the 50 first problems
problems_symbols =
  map(name -> OptimizationProblems.ADNLPProblems.eval(Meta.parse(name)), problems_names)

@testset "NLS from NLP" begin
  result_list_isnls = Bool[]
  for (index, problem) in enumerate(problems_symbols)
    try
      detect_nls = JSOSuite.isnls(problem())
      is_nls = OptimizationProblems.meta[OptimizationProblems.meta.name .== problems_names[index], :objtype][1] == :least_squares
      push!(result_list_isnls, detect_nls)
      if detect_nls
        @test detect_nls == is_nls
        @debug "Least squares objective, $index : $problem"
        # detect_nls != is_nls && (@debug "$index : $problem")
      else
        @debug "Not least squares objective, $index : $problem"
      end
    catch
      @debug "the $index-th $(problems_names[index]) problem is unsupported."
    end
  end
end
