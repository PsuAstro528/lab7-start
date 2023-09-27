using Pkg
Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true   # Tell Julia package manager not to download an updated registry for
Pkg.activate(".")
Pkg.instantiate()  # Not needed if we've already installed packages into this project when we prepared the inputs
Pkg.precompile()   # Make sure packagers are compiled in serial before starting parallel processing.
