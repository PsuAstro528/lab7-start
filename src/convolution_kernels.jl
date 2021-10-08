using Distributions

#export AbstractConvolutionKernel, GaussianConvolutionKernel, GaussianMixtureConvolutionKernel

"""Convolution kernel using a truncated Gaussian with zero mean and unit width.
Optionally truncate at limit_kernel_width (defaults to 10)."""
struct GaussianConvolutionKernel{T} <: AbstractConvolutionKernel  where {T<:Number}
  dist::Normal{T}
  norm::T
  limit_kernel_width::Float64

  function GaussianConvolutionKernel(width::T; limit_kernel_width::Number=limit_kernel_width_default) where {T<:Number}
      @assert width > 0
      @assert limit_kernel_width > width
      dist = Normal(zero(T), width)
      norm = one(T)/(cdf(dist,limit_kernel_width)-cdf(dist,-limit_kernel_width))
      new{T}(dist, norm, limit_kernel_width)
  end
end

"Evaluate kernel at wavelength(s) x"
function (kernel::GaussianConvolutionKernel)(x::Number)
    x < kernel.limit_kernel_width^2 ? kernel.norm*pdf(kernel.dist,x) : zero(x)
end

function (kernel::GaussianConvolutionKernel)(x::A1) where { T1<:Number, A1<:AbstractArray{T1} }
    kernel.(x)
end

"""Convolution kernel using a mixture of Gaussians with zero mean and various width and weights.
Optionally truncate at limit_kernel_width (defaults to 10)."""
struct GaussianMixtureConvolutionKernel{T1,T2} <: AbstractConvolutionKernel  where {T1<:Number,T2<:Number}
    dists::Array{Normal{T1},1}
    weights::Array{T2,1}
    norm::T2
    limit_kernel_width::Float64

    function GaussianMixtureConvolutionKernel(kernel_widths::AbstractArray{T1,1}, kernel_weights::AbstractArray{T2,1};
            limit_kernel_width::Number=limit_kernel_width_default) where {T1<:Number,T2<:Number}
        @assert size(kernel_widths) == size(kernel_weights)
        @assert all(kernel_widths .> 0)
        @assert all(limit_kernel_width .> kernel_widths)
        @assert sum(kernel_weights) ≈ one(eltype(kernel_weights))
        dists = [Normal(zero(kernel_widths[i]),kernel_widths[i]) for i in 1:length(kernel_widths) ]
        cdf_at_limit(d) = cdf(d,limit_kernel_width)
        norm = sum(kernel_weights./(cdf_at_limit.(dists))) # assumes components symmetric around zero
        new{T1,T2}(dists, kernel_weights, norm, limit_kernel_width)
    end
end

"Evaluate kernel at wavelength(s) x"
function (kernel::GaussianMixtureConvolutionKernel)(x::Number)
    abs(x) < kernel.limit_kernel_width ?  kernel.norm*sum(kernel.weights.*pdf.(kernel.dists,x)) : zero(x)
end

function (kernel::GaussianMixtureConvolutionKernel)(x::AbstractArray{T}) where T<:Number
    kernel.(x)
end
