using Distributed
@everywhere (import Pkg; Pkg.offline(true); Pkg.activate(".") )

using NBInclude
println("# About to run Jupyter notebook")
flush(stdout)
@nbinclude("ex2.ipynb")
println("# Completed running notebook")
flush(stdout)
