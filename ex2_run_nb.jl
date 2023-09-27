using NBInclude

println("# About to run Jupyter notebook")
flush(stdout)
flush(stderr)

@nbinclude("ex2.ipynb")
flush(stdout)
flush(stderr)

println("# Completed running notebook")

