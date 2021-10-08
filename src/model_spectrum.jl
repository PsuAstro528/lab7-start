# Constants
const limit_kernel_width_default = 10.0
const speed_of_light = 299792458.0 # m/s

# spectrum.jl:  utils for computing simple spectrum models
include("spectrum.jl")
export AbstractSpectrum, SimpleSpectrum, SimulatedSpectrum, ConvolvedSpectrum
export doppler_shifted_spectrum
#export continuum_model, absorption_lines, gaussian_convolution_kernel
#export std_gaussian_line, absorption_line

# convolution_kernels.jl:  utils for convolution kernels
include("convolution_kernels.jl")
export AbstractConvolutionKernel, GaussianConvolutionKernel, GaussianMixtureConvolutionKernel
