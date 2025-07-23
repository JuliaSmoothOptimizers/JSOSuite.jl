@init begin
  @require CaNNOLeS = "5a1c9e79-9c58-5ec0-afc4-3298fdea2875" begin
    optimizers[optimizers.name .== "CaNNOLeS", :is_available] .= 1
    function minimize(::Val{:CaNNOLeS}, nlp; kwargs...)
      return CaNNOLeS.cannoles(nlp; linsolve = :ldlfactorizations, kwargs...)
    end
  end
end

@init begin
  @require DCISolver = "bee2e536-65f6-11e9-3844-e5bb4c9c55c9" begin
    optimizers[optimizers.name .== "DCISolver", :is_available] .= 1
    function minimize(::Val{:DCISolver}, nlp; kwargs...)
      return DCISolver.dci(nlp; kwargs...)
    end
  end
end

@init begin
  @require FletcherPenaltySolver = "e59f0261-166d-4fee-8bf3-5e50457de5db" begin
    optimizers[optimizers.name .== "FletcherPenaltySolver", :is_available] .= 1
    function minimize(::Val{:FletcherPenaltySolver}, nlp; kwargs...)
      return FletcherPenaltySolver.fps_solve(nlp; kwargs...)
    end
  end
end

@init begin
  @require NLPModelsIpopt = "f4238b75-b362-5c4c-b852-0801c9a21d71" begin
    optimizers[optimizers.name .== "IPOPT", :is_available] .= 1
    include("solvers/ipopt_solve.jl")
  end
end

@init begin
  @require NLPModelsKnitro = "bec4dd0d-7755-52d5-9a02-22f0ffc7efcb" begin
    @init begin
      @require KNITRO = "67920dd8-b58e-52a8-8622-53c4cffbe346" begin
        optimizers[optimizers.name .== "KNITRO", :is_available] .= KNITRO.has_knitro()
      end
    end
    include("solvers/knitro_solve.jl")
  end
end

@init begin
  @require RipQP = "1e40b3f8-35eb-4cd8-8edd-3e515bb9de08" begin
    optimizers[optimizers.name .== "RipQP", :is_available] .= 1
    include("solvers/ripqp_solve.jl")
  end
end
