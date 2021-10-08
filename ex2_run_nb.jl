using Distributed
@everywhere import Pkg
@everywhere Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true   # Tell Julia package manager not to download an updated registry for
@everywhere Pkg.activate(".")
using NBInclude
println("# About to run Jupyter notebook")
flush(stdout)
@nbinclude("ex2.ipynb")
println("# Completed running notebook")
flush(stdout)