using Distributed, SlurmClusterManager;

addprocs(SlurmManager())
#addprocs(SlurmManager(), exeflags=["--project=.",], );

