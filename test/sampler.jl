using KernelDensity

@testset "pdf and Gaussian state data generator" begin
    state = SqueezedThermalState(ξ(1., π/4), 0.5)
    θs = LinRange(0, 2π, 10)
    xs = LinRange(-10, 10, 10)

    ground_truth_pdf = q_pdf(state, θs, xs)

    single_point_pdf = (θ, x) -> q_pdf(state, θ, x)
    @test single_point_pdf.(θs, xs') ≈ ground_truth_pdf

    n = 100000
    data = gaussian_state_sampler(state, n)
    sampled_pdf = pdf(kde((data[1, :], data[2, :])), θs, xs)

    @test sum(abs.(sampled_pdf .- ground_truth_pdf)) / n < 5e-5
end

@testset "pdf and non-Gaussian state data generator" begin
    state = displace!(
        squeeze!(
            SinglePhotonState(rep=StateMatrix, dim=100),
            ξ(0.5, π/2)
        ),
        α(3., π/2)
    )
    θs = LinRange(0, 2π, 10)
    xs = LinRange(-10, 10, 10)

    ground_truth_pdf = q_pdf(state, θs, xs)

    single_point_pdf = (θ, x) -> q_pdf(state, θ, x)
    @test single_point_pdf.(θs, xs') ≈ ground_truth_pdf

    n = 4096
    data = state_sampler(state, n)
    sampled_pdf = pdf(kde((data[1, :], data[2, :])), θs, xs)
    @test sum(abs.(sampled_pdf .- ground_truth_pdf)) / n  < 5e-2

    n = 4096-1
    data = state_sampler(state, n)
    sampled_pdf = pdf(kde((data[1, :], data[2, :])), θs, xs)
    @test sum(abs.(sampled_pdf .- ground_truth_pdf)) / n  < 5e-2

    n = 4100
    data = state_sampler(state, n, warm_up_n=100, batch_size=97)
    sampled_pdf = pdf(kde((data[1, :], data[2, :])), θs, xs)
    @test sum(abs.(sampled_pdf .- ground_truth_pdf)) / n  < 5e-2
end

@testset "wrapping" begin
    state = VacuumState()
    @test size(rand(state, IsGaussian)) == (2, 1)
    @test size(rand(state, 4096, IsGaussian)) == (2, 4096)
    @test size(rand(state, 4100, IsGaussian, bias_phase=π/4)) == (2, 4100)

    state = SinglePhotonState()
    @test size(rand(state)) == (2, 1)
    @test size(rand(state, 4096, show_log=false)) == (2, 4096)
    @test size(rand(state, 4100, warm_up_n=97, show_log=false)) == (2, 4100)
    @test size(rand(state, 4100, warm_up_n=97, batch_size=100, show_log=false)) == (2, 4100)
    @test size(rand(state, 100, warm_up_n=200, batch_size=100, show_log=false)) == (2, 100)
end
