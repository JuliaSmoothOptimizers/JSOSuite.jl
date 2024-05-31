using JSOSuite
using Documenter

DocMeta.setdocmeta!(JSOSuite, :DocTestSetup, :(using JSOSuite); recursive = true)

const page_rename = Dict(
  "developer.md" => "Developer docs",
  "nls.md" => "Nonlinear Least Squares",
  "qp.md" => "Quadratic models with linear constraints",
  "resolve.md" => "Re-solve and in-place solve",
  "speed-up.md" => "Speed up Solvers Tips",
) # Without the numbers

function nice_name(file)
  file = replace(file, r"^[0-9]*-" => "")
  if haskey(page_rename, file)
    return page_rename[file]
  end
  return splitext(file)[1] |> x -> replace(x, "-" => " ") |> titlecase
end

makedocs(;
  modules = [JSOSuite],
  doctest = true,
  linkcheck = false, # Rely on Lint.yml/lychee for the links
  authors = "Tangi Migot <tangi.migot@gmail.com> and contributors",
  repo = "https://github.com/JuliaSmoothOptimizers/JSOSuite.jl/blob/{commit}{path}#{line}",
  sitename = "JSOSuite.jl",
  format = Documenter.HTML(;
    prettyurls = true,
    canonical = "https://JuliaSmoothOptimizers.github.io/JSOSuite.jl",
    assets = ["assets/style.css"],
  ),
  pages = [
    "Home" => "index.md"
    [
      nice_name(file) => file for
      file in readdir(joinpath(@__DIR__, "src")) if file != "index.md" && splitext(file)[2] == ".md"
    ]
  ],
)

deploydocs(; repo = "github.com/JuliaSmoothOptimizers/JSOSuite.jl", push_preview = true)
