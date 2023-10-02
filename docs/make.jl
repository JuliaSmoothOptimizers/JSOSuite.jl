using JSOSuite
using Documenter

DocMeta.setdocmeta!(JSOSuite, :DocTestSetup, :(using JSOSuite); recursive = true)

makedocs(;
  modules = [JSOSuite],
  doctest = true,
  linkcheck = true,
  authors = "Tangi Migot <tangi.migot@gmail.com> and contributors",
  repo = "https://github.com/JuliaSmoothOptimizers/JSOSuite.jl/blob/{commit}{path}#{line}",
  sitename = "JSOSuite.jl",
  format = Documenter.HTML(;
    prettyurls = get(ENV, "CI", "false") == "true",
    canonical = "https://JuliaSmoothOptimizers.github.io/JSOSuite.jl",
    assets = ["assets/style.css"],
  ),
  pages = [
    "Home" => "index.md",
    "Tutorial" => "tutorial.md",
    "Nonlinear Least Squares" => "nls.md",
    "Quadratic models with linear constraints" => "qp.md",
    "Benchmarking" => "benchmark.md",
    "Speed up Solvers Tips" => "speed-up.md",
    "Contributing" => "contributing.md",
    "Dev setup" => "developer.md",
    "Reference" => "reference.md",
  ],
)

deploydocs(; repo = "github.com/JuliaSmoothOptimizers/JSOSuite.jl", push_preview = true)
