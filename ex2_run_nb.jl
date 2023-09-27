using NBInclude

ENV["GKSwstype"]="nul"   # To prevent Plots pacakge from trying to display plot

println("# About to run Jupyter notebook")
flush(stdout)
flush(stderr)

@nbinclude("ex2.ipynb")
flush(stdout)
flush(stderr)

println("# Completed running notebook")

