using JSOSuite
using Documenter

DocMeta.setdocmeta!(JSOSuite, :DocTestSetup, :(using JSOSuite); recursive = true)

const page_rename = Dict("developer.md" => "Developer docs") # Without the numbers
const numbered_pages = [
  file for
  file in readdir(joinpath(@__DIR__, "src")) if file != "index.md" && splitext(file)[2] == ".md"
]

makedocs(;
  modules = [JSOSuite],
  authors = "Tangi Migot <tangi.migot@gmail.com> and contributors",
  repo = "https://github.com/JuliaSmoothOptimizers/JSOSuite.jl/blob/{commit}{path}#{line}",
  sitename = "JSOSuite.jl",
  format = Documenter.HTML(; canonical = "https://JuliaSmoothOptimizers.github.io/JSOSuite.jl"),
  pages = ["index.md"; numbered_pages],
)

deploydocs(; repo = "github.com/JuliaSmoothOptimizers/JSOSuite.jl")
