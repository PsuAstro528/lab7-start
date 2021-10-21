using Pkg
Pkg.offline(true)
Pkg.activate(".")
Pkg.instantiate()

using CSV
using DataFrames

job_sizes = [ 10_000, 100_000 ]
num_jobs_per_size = 5
num_sizes = length(job_sizes)
num_jobs = num_jobs_per_size * num_sizes

array_ids = collect(1:num_jobs)
num_itterations = Int64[]
mapreduce(n->fill(n,num_jobs_per_size), append!, job_sizes, init=num_itterations)
seeds = rand( 1:typemax(UInt32), num_jobs)
df = DataFrame( array_id=array_ids,  seed=seeds,  n=num_itterations )

CSV.write("ex1_job_array_in.csv",df )

