using StatsBase
using StatsBase: PValue
using Test, Random

v1 = [1.45666, -23.14, 1.56734e-13]
v2 = ["Good", "Great", "Bad"]
v3 = [1, 56, 2]
v4 = [-12.56, 0.1326, 2.68e-16]
v5 = [0.12, 0.3467, 1.345e-16]
ct = CoefTable(Any[v1, v2, v3, v4, v5],
               ["Estimate", "Comments", "df", "t", "p"],
               ["x1", "x2", "x3"], 5, 4)
@test sprint(show, ct) == """
───────────────────────────────────────────────
         Estimate  Comments  df       t       p
───────────────────────────────────────────────
x1    1.45666         Good    1  -12.56  0.1200
x2  -23.14            Great  56    0.13  0.3467
x3    1.56734e-13     Bad     2    0.00  <1e-15
───────────────────────────────────────────────"""
@test length(ct) === 3
@test eltype(ct) ==
    NamedTuple{(:Name, :Estimate, :Comments, :df, :t, :p),
               Tuple{String,Float64,String,Int,Float64,Float64}}
@test collect(ct) == [
    (Name = "x1", Estimate = 1.45666, Comments = "Good", df = 1, t = -12.56, p = 0.12)
    (Name = "x2", Estimate = -23.14, Comments = "Great", df = 56, t = 0.1326, p = 0.3467)
    (Name = "x3", Estimate = 1.56734e-13, Comments = "Bad", df = 2, t = 2.68e-16, p = 1.345e-16)
]

Random.seed!(10)
m = rand(3,4)
ct = CoefTable(m, ["Estimate", "Stderror", "df", "p"], [], 4)
@test sprint(show, ct) == """
──────────────────────────────────────────
     Estimate   Stderror        df       p
──────────────────────────────────────────
[1]  0.112582  0.0566454  0.381813  0.8198
[2]  0.368314  0.120781   0.815104  0.6699
[3]  0.344454  0.179574   0.242208  0.4531
──────────────────────────────────────────"""
@test length(ct) === 3
@test eltype(ct) ==
    NamedTuple{(:Estimate, :Stderror, :df, :p),
               Tuple{Float64,Float64,Float64,Float64}}
@test collect(ct) == [
    (Estimate = 0.11258244478647295, Stderror = 0.05664544616214151,
     df = 0.38181274408522614, p = 0.8197779704008801)
    (Estimate = 0.36831406658084287, Stderror = 0.12078054506961555,
     df = 0.8151038332483567, p = 0.6699313951612162)
    (Estimate = 0.3444540231363058, Stderror = 0.17957407667101322,
     df = 0.2422083248151139, p = 0.4530583319523316)
]

@test sprint(show, PValue(1.0)) == "1.0000"
@test sprint(show, PValue(1e-1)) == "0.1000"
if VERSION > v"1.6.0-DEV"
    @test sprint(show, PValue(1e-5)) == "<1e-04"
else
    @test sprint(show, PValue(1e-5)) == "<1e-4"
end
@test sprint(show, PValue(NaN)) == "NaN"
@test_throws ErrorException PValue(-0.1)
@test_throws ErrorException PValue(1.1)
@test PValue(PValue(0.05)) === PValue(0.05)

@test sprint(showerror, ConvergenceException(10)) == "failure to converge after 10 iterations."

@test sprint(showerror, ConvergenceException(10, 0.2, 0.1)) ==
    "failure to converge after 10 iterations. Last change (0.2) was greater than tolerance (0.1)."

@test sprint(showerror, ConvergenceException(10, 0.2, 0.1, "Try changing maxIter.")) ==
    "failure to converge after 10 iterations. Last change (0.2) was greater than tolerance (0.1). Try changing maxIter."

err = @test_throws ArgumentError ConvergenceException(10,.1,.2)
@test err.value.msg == "Change must be greater than tol."
