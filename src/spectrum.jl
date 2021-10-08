include("absorption_line.jl")
include("continuum.jl")

using QuadGK

#export AbstractSpectrum, SimpleSpectrum, SimulatedSpectrum, ConvolvedSpectrum

abstract type AbstractSpectrum end

"Wrapper to turn an arbitrary function of one variable into a sub-type of AbstractSpectrum."
struct SimpleSpectrum <: AbstractSpectrum
    spectrum::Function
    function SimpleSpectrum(f::Function)
        new(f)
    end
end

"Evaluate simple spectrum at wavelength(s) x."
function (s::SimpleSpectrum)(x::Number)
    s.spectrum(x)
end

function (s::SimpleSpectrum)(x::A1) where { T1<:Number, A1<:AbstractArray{T1} }
    s.spectrum(x)
end

"Simulated spectrum consists of stellar lines, telluric lines, and optionally continuum and Doppler shift."
struct SimulatedSpectrum{T1,T2,T3,T4,T5,T6,T7,T8,T9} <: AbstractSpectrum
    star_line_locs::Array{T1,1}
    star_line_widths::Array{T2,1}
    star_line_depths::Array{T3,1}
    telluric_line_locs::Array{T4,1}
    telluric_line_widths::Array{T5,1}
    telluric_line_depths::Array{T6,1}
    continuum_param::Array{T7,1}
    z::T8
    lambda_mid::T9
    limit_line_effect::T9

    function SimulatedSpectrum(star_line_locs::Array{T1,1}, star_line_widths::Array{T2,1}, star_line_depths::Array{T3,1},
        telluric_line_locs::Array{T4,1}, telluric_line_widths::Array{T5,1}, telluric_line_depths::Array{T6,1};
        continuum_param::Array{T7,1} = [1.0], z::T8 = 0.0, lambda_mid::T9 = 0.0, limit_line_effect::T9 = Inf
        ) where {T1<:Number, T2<:Number, T3<:Number, T4<:Number, T5<:Number, T6<:Number, T7<:Number, T8<:Number, T9<:Number}
        @assert length(star_line_locs) == length(star_line_widths) == length(star_line_depths)
        @assert length(telluric_line_locs) == length(telluric_line_widths) == length(telluric_line_depths)
        @assert length(continuum_param) >= 1
        new{T1,T2,T3,T4,T5,T6,T7,T8,T9}(star_line_locs,star_line_widths,star_line_depths,
            telluric_line_locs,telluric_line_widths,telluric_line_depths,
            continuum_param,z,lambda_mid,limit_line_effect)
    end
end

#=
"Simulated spectrum consists of stellar lines, telluric lines, and optionally continuum and Doppler shift."
struct SimulatedSpectrumGpu{T1,T2,T3,T4,T5,T6,T7,T8,T9} <: AbstractSpectrum
    star_line_locs::CuArray{T1,1}
    star_line_widths::CuArray{T2,1}
    star_line_depths::CuArray{T3,1}
    telluric_line_locs::CuArray{T4,1}
    telluric_line_widths::CuArray{T5,1}
    telluric_line_depths::CuArray{T6,1}
    continuum_param::CuArray{T7,1}
    z::T8
    lambda_mid::T9
    limit_line_effect::T9

    function SimulatedSpectrumGpu(star_line_locs::Array{T1,1}, star_line_widths::Array{T2,1}, star_line_depths::Array{T3,1},
        telluric_line_locs::Array{T4,1}, telluric_line_widths::Array{T5,1}, telluric_line_depths::Array{T6,1};
        continuum_param::Array{T7,1} = [1.0], z::T8 = 0.0, lambda_mid::T9 = 0.0, limit_line_effect::T9 = Inf
        ) where {T1<:Number, T2<:Number, T3<:Number, T4<:Number, T5<:Number, T6<:Number, T7<:Number, T8<:Number, T9<:Number}
        @assert length(star_line_locs) == length(star_line_widths) == length(star_line_depths)
        @assert length(telluric_line_locs) == length(telluric_line_widths) == length(telluric_line_depths)
        @assert length(continuum_param) >= 1
        new{T1,T2,T3,T4,T5,T6,T7,T8,T9}(cu(star_line_locs),cu(star_line_widths),cu(star_line_depths),
            cu(telluric_line_locs),cu(telluric_line_widths),cu(telluric_line_depths),
            cu(continuum_param),z,lambda_mid,limit_line_effect)
    end
end
=#

"Evaluate simulated spectrum at wavelength(s) x."
function (spectrum::AbstractSpectrum)(x::Number)
    continuum_model(x*(one(spectrum.z)+spectrum.z),spectrum.continuum_param,center=spectrum.lambda_mid) *
            absorption_lines(x*(one(spectrum.z)+spectrum.z), spectrum.star_line_locs, spectrum.star_line_widths, spectrum.star_line_depths, limit_line_effect=spectrum.limit_line_effect ) *
            absorption_lines(x, spectrum.telluric_line_locs, spectrum.telluric_line_widths, spectrum.telluric_line_depths, limit_line_effect=spectrum.limit_line_effect )
end

function (spectrum::AbstractSpectrum)(x::A) where { T<:Number, A<:AbstractArray{T} }
    #@inbounds spectrum.(x)
    f_cont(y) = continuum_model(y*(one(spectrum.z)+spectrum.z),spectrum.continuum_param,center=spectrum.lambda_mid)
    f_star(y) = absorption_lines(y*(one(spectrum.z)+spectrum.z), spectrum.star_line_locs, spectrum.star_line_widths, spectrum.star_line_depths, limit_line_effect=spectrum.limit_line_effect )
    f_telluric(y) = absorption_lines(y, spectrum.telluric_line_locs, spectrum.telluric_line_widths, spectrum.telluric_line_depths, limit_line_effect=spectrum.limit_line_effect )
    @inbounds f_cont.(x) .* f_star.(x) .* f_telluric.(x)
end

abstract type AbstractConvolutionKernel end

"Spectrum based on conlving another spectrum with a point spread function.  Optionally, limit the width of the convolution."
struct ConvolvedSpectrum{T1,T2} <: AbstractSpectrum
    spectrum::T1
    kernel::T2
    limit_conv_width::Float64
    function ConvolvedSpectrum(spectrum::T1, kernel::T2;
         limit_conv_width = limit_kernel_width_default) where {T1<:AbstractSpectrum, T2<:AbstractConvolutionKernel}
        new{T1,T2}(spectrum,kernel,limit_conv_width)
    end
end

"Evaluate the convolved spectrum a wavelenth(s) x"
function (s::ConvolvedSpectrum)(x::Number)
    quadgk(y -> s.spectrum(x+y) * s.kernel(y),
                -s.limit_conv_width,s.limit_conv_width)[1]
end

# Inefficient since integration allocates arrays rather than scalars
function (s::ConvolvedSpectrum)(x::A) where { T<:Number, A<:AbstractArray{T} }
    @inbounds quadgk(y -> s.spectrum(x.+y) .* s.kernel.(y),
                -s.limit_conv_width,s.limit_conv_width)[1]
end

"Create same simulated spectrum but replacing the Doppler shift parameter (z)."
function doppler_shifted_spectrum(s::AbstractSpectrum, z::Number) end

function doppler_shifted_spectrum(s::SimulatedSpectrum, z::Number)
    SimulatedSpectrum(s.star_line_locs, s.star_line_widths,s.star_line_depths,
            s.telluric_line_locs,s.telluric_line_widths,s.telluric_line_depths,
            continuum_param=s.continuum_param, z=z,
            lambda_mid=s.lambda_mid, limit_line_effect=s.limit_line_effect)
end

function doppler_shifted_spectrum(s::ConvolvedSpectrum{T1,T2}, z::Number) where {
                T1<:AbstractSpectrum, T2<:AbstractConvolutionKernel }
    ConvolvedSpectrum(doppler_shifted_spectrum(s.spectrum,z), s.kernel,
            limit_conv_width=s.limit_conv_width)
end
