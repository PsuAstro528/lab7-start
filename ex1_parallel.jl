using Distributed 
@everywhere using ParallelUtilities

@everywhere function calc_pi(n::Integer)
   x = rand(n)
   y = rand(n)
   num_in_unit_circle = sum(x.*x.+y.*y .< 1)
   num_in_unit_circle * 4/n
end

n = 10_000_000;
n_per_worker = round(Int64,n//nworkers())
n_actual = n_per_worker * nworkers()
pmapreduce(calc_pi, +, fill(1, nworkers()) ) / nworkers()
@time pi_estimate = pmapreduce(calc_pi, +, fill(n_per_worker, nworkers()) ) / nworkers()
println("# After ", n_per_worker, " itterations on each of ", nworkers(), " workers, estimated pi to be...")
println(pi_estimate)
