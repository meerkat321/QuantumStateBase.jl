module QuantumStateBase
    using InfiniteArrays
    using LinearAlgebra
    using ClassicalOrthogonalPolynomials

    # polynomial
    include("polynomial.jl")

    # state
    include("operator.jl")
    include("state.jl")

    # wigner
    # include("wigner_util.jl")
    # include("wigner.jl")

    # pdf of quadrature
    # include("quadrature_pdf.jl")
    # include("sampler.jl")
end
