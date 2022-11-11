using BenchmarkTools, DataFrames, Dates, DelimitedFiles, JLD2, Random
#JSO packages
using JSOSuite

Random.seed!(1234)

const SUITE = BenchmarkGroup()

using CUTEst

include("cutest_equality.jl")

tune!(SUITE)
BenchmarkTools.save(params(SUITE))
