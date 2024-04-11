using Documenter, JSOSuite

makedocs(
  modules = [JSOSuite],
  doctest = true,
  # linkcheck = true,
  strict = true,
  format = Documenter.HTML(
    assets = ["assets/style.css"],
    prettyurls = get(ENV, "CI", nothing) == "true",
  ),
  sitename = "JSOSuite.jl",
  pages = Any[
    "Home" => "index.md",
    "Tutorial" => "tutorial.md",
    "Nonlinear Least Squares" => "nls.md",
    "Quadratic models with linear constraints" => "qp.md",
    "Resolve and in-place solve" => "resolve.md",
    "Benchmarking" => "benchmark.md",
    "Speed up Solvers Tips" => "speed-up.md",
    "Reference" => "reference.md",
  ],
)

deploydocs(
  repo = "github.com/JuliaSmoothOptimizers/JSOSuite.jl.git",
  push_preview = true,
  devbranch = "main",
)
