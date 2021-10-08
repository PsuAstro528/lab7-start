export continuum_model

"Compute the mean continuum flux as a function of wavelength (x) using polynomial model (coeff)."
function continuum_model(x::T1, coeff::A2; center = zero(typeof(x)) ) where { T1<:Number, T2<:Number, A2<:AbstractVector{T2} }
    #@assert 2 <= length(coeff) <= 10
    y = coeff[end]
    for i in (length(coeff)-1):-1:1      # a range starting a degree and running backwards to 1
        y *= (x.-center)
        y += coeff[i]
    end
    return y
end

function continuum_model(x::A1, coeff::A2; center = zero(typeof(x)) ) where { T1<:Number, T2<:Number, A1<:AbstractArray{T1}, A2<:AbstractVector{T2} }
    f(y) = continuum_model(y,coeff,center=center)  # make helper function so that broadcasting over x is unambiguous
    @inbounds f.(x)
end
