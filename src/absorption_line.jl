"Compute a transmission coefficient for a Gaussian absorption line with given depth.  Optionally, truncate absorption at limit_line_effect."
function std_gaussian_line(x::Number, depth::Number; limit_line_effect = Inf)
   return abs(x)>limit_line_effect ? one(x) : one(x)-depth*exp(-0.5*x^2)
end

"Compute spectrum for an Gaussian absorption line give it's location, width and depth"
function absorption_line(x::Number, location::Number, width::Number, depth::Number; limit_line_effect = Inf)
    std_gaussian_line((x-location)/width, depth, limit_line_effect=limit_line_effect)
end


"Compute product of absorption lines at one wavelength given a list of locations, widths and depths"
function absorption_lines(x::T1, locations::A2, widths::A3, depths::A4; limit_line_effect = Inf) where { T1<:Number, T2<:Number, T3<:Number, T4<:Number, A2<:AbstractVector{T2}, A3<:AbstractVector{T3}, A4<:AbstractVector{T4} }
    @assert length(locations) == length(widths) == length(depths) >= 1
    @inbounds trans = absorption_line(x, locations[1], widths[1], depths[1], limit_line_effect = limit_line_effect )
    for i in 2:length(locations)
        @inbounds trans = trans * absorption_line(x, locations[i],widths[i], depths[i], limit_line_effect = limit_line_effect )
    end
    return trans
end

function absorption_lines(x::A1, locations::A2, widths::A3, depths::A4; limit_line_effect = Inf) where { T1<:Number, T2<:Number, T3<:Number, T4<:Number, A1<:AbstractArray{T1}, A2<:AbstractVector{T2}, A3<:AbstractVector{T3}, A4<:AbstractVector{T4} }
    @assert length(locations) == length(widths) == length(depths) >= 1
    trans = absorption_line.(x, locations[1], widths[1], depths[1], limit_line_effect = limit_line_effect )
    @inbounds for i in 2:length(locations)
        trans = trans .* absorption_line.(x, locations[i],widths[i], depths[i], limit_line_effect = limit_line_effect )
    end
    return trans
end
