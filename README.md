# JSOSuite.jl

[![docs-stable][docs-stable-img]][docs-stable-url] [![docs-dev][docs-dev-img]][docs-dev-url] [![build-ci][build-ci-img]][build-ci-url] [![codecov][codecov-img]][codecov-url] [![release][release-img]][release-url]

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://JuliaSmoothOptimizers.github.io/JSOSuite.jl/stable
[docs-dev-img]: https://img.shields.io/badge/docs-dev-purple.svg
[docs-dev-url]: https://JuliaSmoothOptimizers.github.io/JSOSuite.jl/dev
[build-ci-img]: https://github.com/JuliaSmoothOptimizers/JSOSuite.jl/workflows/CI/badge.svg?branch=main
[build-ci-url]: https://github.com/JuliaSmoothOptimizers/JSOSuite.jl/actions
[codecov-img]: https://codecov.io/gh/JuliaSmoothOptimizers/JSOSuite.jl/branch/main/graph/badge.svg
[codecov-url]: https://codecov.io/gh/JuliaSmoothOptimizers/JSOSuite.jl
[release-img]: https://img.shields.io/github/v/release/JuliaSmoothOptimizers/JSOSuite.jl.svg?style=flat-square
[release-url]: https://github.com/JuliaSmoothOptimizers/JSOSuite.jl/releases

One stop solutions for all things optimization.

## How to Cite

If you use JSOSuite.jl in your work, please cite using the format given in [CITATION.cff](https://github.com/JuliaSmoothOptimizers/JSOSuite.jl/blob/main/CITATION.cff).

## Installation

```
] add JSOSuite
```

## Example

```julia
using JSOSuite, ADNLPModels

# Rosenbrock
nlp = ADNLPModel(x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0])
stats = solve(nlp)

# Constrained
nlp = ADNLPModel(x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0],
                 x->[x[1] * x[2] - 1], [0.0], [0.0])
stats = solve(nlp)
```

# Bug reports and discussions

If you think you found a bug, feel free to open an [issue](https://github.com/JuliaSmoothOptimizers/JSOSuite.jl/issues).
Focused suggestions and requests can also be opened as issues. Before opening a pull request, start an issue or a discussion on the topic, please.

If you want to ask a question not suited for a bug report, feel free to start a discussion [here](https://github.com/JuliaSmoothOptimizers/Organization/discussions). This forum is for general discussion about this repository and the [JuliaSmoothOptimizers](https://github.com/JuliaSmoothOptimizers), so questions about any of our packages are welcome.
