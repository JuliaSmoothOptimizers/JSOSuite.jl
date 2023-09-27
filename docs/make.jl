using Documenter, JSOSuite

makedocs(
  modules = [JSOSuite],
  doctest = true,
  linkcheck = true,
  format = Documenter.HTML(
    assets = ["assets/style.css"],
    prettyurls = get(ENV, "CI", nothing) == "true",
  ),
  sitename = "JSOSuite.jl",
  pages = [
    "Home" => "index.md",
    "Tutorial" => "tutorial.md",
    "Nonlinear Least Squares" => "nls.md",
    "Quadratic models with linear constraints" => "qp.md",
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
