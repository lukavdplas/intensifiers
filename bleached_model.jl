### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ 9618f500-1464-11eb-1392-71fd1a08f733
begin
	include("weather.jl")
	include("valence.jl")
end

# ╔═╡ 1d6b6f7a-0d61-11eb-288b-911cc4f27369
md"""
## Possible worlds and messages

The possible worlds are defined by their temperature. Temperatures range from -10 to 50 °C.
"""

# ╔═╡ 5d8e8c22-0d5c-11eb-1398-db1ee99ce9d1
temperatures = -10:50

# ╔═╡ 791db33c-1464-11eb-132f-a1ae29ed628c
md"""
## Code import

We import code on the prior distribution of temperatures, the valence of messages.
"""

# ╔═╡ 0a0ab47c-0d61-11eb-324b-c5b2c1e91d22
md"""
## Model definition

We define a literal listener, a speaker and a pragmatic listener.

### Literal listener
"""

# ╔═╡ d4a54716-0d5b-11eb-0a16-753470a2251a
function literal_listener(degree::Int, message::String, θ)
	if degree < θ
		0.0
	else
		prior(degree) / prior_range(θ, last(temperatures))
	end
end

# ╔═╡ 35b6004c-1467-11eb-3fad-19556d5cd64f
md"""
### Speaker
"""

# ╔═╡ d6582570-0d5d-11eb-28f0-ffb9703ffdc6
function cost(message, γ)
	if message != "null" 
		γ * (1 - valence(message))
	else
		0
	end
end

# ╔═╡ 83cde2ba-0d5d-11eb-3a96-957db0095676
function utility(degree, message, θ, γ)
	log(literal_listener(degree, message, θ)) - cost(message, γ)
end

# ╔═╡ 36206f76-0d5e-11eb-1a6f-a9df99c1a543
function speaker(degree::Int, message::String, θs, λ, γ)
	messages = keys(θs)
	u(m) = exp(λ * utility(degree, m, θs[m], γ))
	
	u(message) / sum(u.(messages))
end

# ╔═╡ 3e4f5f1e-1467-11eb-2547-b15e947823e5
md"""
### Pragmatic listener
"""

# ╔═╡ 9273de26-0d5f-11eb-00ab-09d6d96b3142
function listener(degree::Int, message::String, λ, γ)
	not_normalised(d) = let
		speaker_given_θ(θ) = let
			θs = Dict("null" => first(temperatures), 
				message => θ)
			speaker(d, message, θs, λ, γ)
		end
	
		prior(d) * sum(map(speaker_given_θ, temperatures))
	end
	
	not_normalised(degree) / sum(not_normalised.(temperatures))
end

# ╔═╡ 9f05e130-0d72-11eb-065f-0943c6ca045c
function listener_expectation(message, λ, γ)
	posteriors = map(t -> listener(t, message, λ, γ), temperatures)
	sum(temperatures .* posteriors) / sum(posteriors)
end

# ╔═╡ 4b6a77c4-1467-11eb-31fd-692d4b218d2c
md"""
### Full model

The full model definition takes the parameters `λ` and `γ` and returns the model as a function. This function takes a message and returns the expected temperature, as defined by the pragmatic listener.
"""

# ╔═╡ 90930d48-1467-11eb-37ad-d71d5fe33c21
function model(λ, γ)
	message -> listener_expectation(message, λ, γ)
end

# ╔═╡ Cell order:
# ╟─1d6b6f7a-0d61-11eb-288b-911cc4f27369
# ╠═5d8e8c22-0d5c-11eb-1398-db1ee99ce9d1
# ╟─791db33c-1464-11eb-132f-a1ae29ed628c
# ╠═9618f500-1464-11eb-1392-71fd1a08f733
# ╟─0a0ab47c-0d61-11eb-324b-c5b2c1e91d22
# ╠═d4a54716-0d5b-11eb-0a16-753470a2251a
# ╟─35b6004c-1467-11eb-3fad-19556d5cd64f
# ╠═36206f76-0d5e-11eb-1a6f-a9df99c1a543
# ╠═83cde2ba-0d5d-11eb-3a96-957db0095676
# ╠═d6582570-0d5d-11eb-28f0-ffb9703ffdc6
# ╟─3e4f5f1e-1467-11eb-2547-b15e947823e5
# ╠═9273de26-0d5f-11eb-00ab-09d6d96b3142
# ╠═9f05e130-0d72-11eb-065f-0943c6ca045c
# ╟─4b6a77c4-1467-11eb-31fd-692d4b218d2c
# ╠═90930d48-1467-11eb-37ad-d71d5fe33c21
