export
    create,
    annihilate,
    displace,
    squeeze

############
# a† and a #
############
"""
    QuantumStateBase.Creation(T; dim::Integer)

Creation operator in matrix form.

``\\hat{a}^{\\dagger}``
"""
Creation(T; dim::Integer) = .√(diagm(-1 => T.(Base.OneTo(dim-1))))

"""
    create(v::AbstractVector{T})

    create(ρ::AbstractMatrix{T})

Apply creation operator on a quantum state.

## Arguments

* `v`: A quantum state vector.
* `ρ`: Density matrix of a quantum state.

## Examples

```julia-repl
julia> state = VacuumState(dim = 5);

julia> new_state = Create(state);

julia> new_state == SinglePhotonState(dim = 5)
true
```
"""
function create(v::AbstractVector{T}) where {T}
    dim = length(v)

    return Creation(T, dim=dim) * v
end

function create(ρ::AbstractMatrix{T}) where {T}
    dim = size(ρ, 1)
    c = Creation(T, dim=dim)

    return c * ρ * c'
end

"""
    QuantumStateBase.Annihilation(T; dim::Integer)

Annihilation operator in matrix form.

``\\hat{a}``
"""
Annihilation(T; dim::Integer) = .√(diagm(1 => T.(Base.OneTo(dim-1))))

"""
    annihilate(v::AbstractVector{T})

    annihilate(ρ::AbstractMatrix{T})

Apply annihilation operator on a quantum state.

## Arguments

* `v`: A quantum state vector.
* `ρ`: Density matrix of a quantum state.

## Examples

```julia-repl
julia> state = SinglePhotonState(dim = 5);

julia> new_state = annihilate(state);

julia> new_state == VacuumState(dim = 5)
true
```
"""
function annihilate(v::AbstractVector{T}) where {T}
    dim = length(v)

    return Annihilation(T, dim=dim) * v
end

function annihilate(ρ::AbstractMatrix{T}) where {T}
    dim = size(ρ, 1)
    a = Annihilation(T, dim=dim)

    return a * ρ * a'
end

###########
# α and ξ #
###########

struct ComplexVec{T<:Real}
    r::T
    θ::T
end

"""
    QuantumStateBase.ComplexVec(r::T, θ::T)

Vector in polar coordinate for complex plane.

``v = re^{-i\\theta}``

## Arguments

* `r`: Radius of the complex number.
* `θ`: Argument of the complex number.
"""
ComplexVec(r::T, θ::T) where {T} = ComplexVec{T}(r, θ)

function Base.show(io::IO, complexvec::ComplexVec{T}) where {T}
    print(io, "ComplexVec{$T}($(complexvec.r)exp(-$(complexvec.θ)im))")
end

"""
    QuantumStateBase.z(complexvec::ComplexVec)

Evaluate the complex vector.
"""
z(complexvec::ComplexVec) = complexvec.r * exp(-im * complexvec.θ)

################
# displacement #
################
"""
    QuantumStateBase.Displacement(T::Type{<:Complex}, r::Real, θ::Real; dim)

Displacement operator in matrix form.

``\\hat{D}(\\alpha) = exp(\\alpha \\hat{a}^{\\dagger} - \\alpha^{*} \\hat{a})``
"""
function Displacement(T::Type{<:Complex}, r::Real, θ::Real; dim)
    U = real(T)
    α = ComplexVec(U(r), U(θ))

    return exp(
        z(α) * Creation(U, dim=dim) - z(α)' * Annihilation(U, dim=dim)
    )
end

"""
    displace(v::AbstractVector{T}, r, θ)

    displace(ρ::AbstractMatrix{T}, r, θ)

Apply displacement operator on a quantum state.

## Arguments

* `v`: A quantum state vector.
* `ρ`: Density matrix of a quantum state.
* `r`: Radius of displacement.
* `θ`: Phase of displacement.

## Examples

```julia-repl
julia> state = VacuumState(dim = 5);

julia> new_state = displace(state, 2, π/4);

julia> new_state == CoherentState(2, π/4, dim = 5)
true
```
"""
function displace(v::AbstractVector{T}, r, θ) where {T}
    dim = length(v)

    return Displacement(complex(T), r, θ, dim=dim) * v
end

function displace(ρ::AbstractMatrix{T}, r, θ) where {T}
    dim = size(ρ, 1)
    d = Displacement(complex(T), r, θ, dim=dim)

    return d * ρ * d'
end

#############
# squeezing #
#############

"""
    QuantumStateBase.Squeezing(T::Type{<:Complex}, r::Real, θ::Real; dim)

Squeezing operator in matrix form.

## Arguments

* `r`: Squeezing level.
* `θ`: Squeezing phase.

``\\hat{S}(\\xi) = exp(\\frac{1}{2}(\\xi^{*} \\hat{a}^{2} - \\xi \\hat{a}^{\\dagger 2}))``
"""
function Squeezing(T::Type{<:Complex}, r::Real, θ::Real; dim)
    U = real(T)
    ξ = ComplexVec(U(r), U(θ))

    return exp(
        (z(ξ)' * Annihilation(U, dim=dim)^2)/2 - (z(ξ) * Creation(U, dim=dim)^2)/2
    )
end

"""
    squeeze(v::AbstractVector{T})

    squeeze(ρ::AbstractMatrix{T})

Apply squeezing operator on a quantum state.

## Arguments

* `v`: A quantum state vector.
* `ρ`: Density matrix of a quantum state.
* `r`: Squeezing level.
* `θ`: Squeezing phase.

## Examples

```julia-repl
julia> state = VacuumState(dim = 5);

julia> new_state = squeeze(state, 0.5, π/4);

julia> new_state == SqueezedState(0.5, π/4, dim = 5)
true
```
"""
function squeeze(v::AbstractVector{T}, r, θ) where {T}
    dim = length(v)

    return Squeezing(complex(T), r, θ, dim=dim) * v
end

function squeeze(ρ::AbstractMatrix{T}, r, θ) where {T}
    dim = size(ρ, 1)
    s = Squeezing(complex(T), r, θ, dim=dim)

    return s * ρ * s'
end
