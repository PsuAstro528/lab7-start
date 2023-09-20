function calc_pi(n::Integer)
   x = rand(n)
   y = rand(n)
   num_in_unit_circle = sum(x.*x.+y.*y .< 1)
   num_in_unit_circle * 4/n
end

n = 10_000_000;
calc_pi(1)  # Force compile
@time pi_estimate = calc_pi(n)
println("# After ", n, " itterations, estimated pi to be...")
println(pi_estimate)
