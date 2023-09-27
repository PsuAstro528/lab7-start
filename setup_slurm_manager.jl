import Pkg
Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true   # Tell Julia package manager not to download an updated registry for speed's sake
#Pkg.activate(".")
Pkg.instantiate()  
Pkg.precompile()

using Distributed, SlurmClusterManager;

addprocs(SlurmManager(), exeflags=["--project=$(Base.active_project())",] )

@everywhere (import Pkg; Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true;)   

