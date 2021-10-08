using Distributed

@everywhere function calc_pi(n::Integer)
   x = rand(n)
   y = rand(n)
   num_in_unit_circle = sum(x.*x.+y.*y .< 1)
   num_in_unit_circle * 4/n
end

n = 100_000;
mapreduce(calc_pi, +, Iterators.repeated(1, nworkers()) ) / nworkers()
@time pi_estimate = mapreduce(calc_pi, +, Iterators.repeated(n, nworkers()) ) / nworkers()
println("# After ", n, " itterations on each of ", nworkers(), " workers, estimated pi to be...")
println(pi_estimate)
