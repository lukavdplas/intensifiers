### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ 9ba90dda-0d42-11eb-2786-894bf5d128e9
using Distributions

# ╔═╡ 2d3a1750-0d64-11eb-2444-835bdf4982b2
using Plots

# ╔═╡ 1d6b6f7a-0d61-11eb-288b-911cc4f27369
md"""
## Possible worlds and messages

The possible worlds are defined by their temperature. Temperatures range from -10 to 50 °C.
"""

# ╔═╡ 5d8e8c22-0d5c-11eb-1398-db1ee99ce9d1
temperatures = -10:50

# ╔═╡ 6ed46d94-0d61-11eb-08cd-57c807d997d1
md"""The messages are either nothing (`"null"`), or _It is warm today_ (`"warm"`).
"""

# ╔═╡ 65aa2d94-0d5c-11eb-3e91-59f2d7d9b912
messages = ["null", "warm"]

# ╔═╡ a0a4b8de-0d60-11eb-275a-3106e8fd8afe
md"""
## Prior distribution

Definition of the prior distribution of temperatures. We also define two convenience functions to get the prior probability of a particular degree and the total prior probability of a range. The latter uses the built-in cumulative density function of the distribution, rather than summing over all the values.
"""

# ╔═╡ b26a8ad8-0d42-11eb-2f59-7170495b6e55
prior_temp = Normal(16.962, 7.688)

# ╔═╡ c239f65e-0d5f-11eb-0c7c-e1ad78c7993b
prior(degree) = pdf(prior_temp, degree)

# ╔═╡ f142fcf2-0d5f-11eb-093b-ff8db091db27
prior_range(lower, upper) = cdf(prior_temp, upper + 1) - cdf(prior_temp, lower)

# ╔═╡ a0c73006-0e20-11eb-3592-3b0206ad76c2
plot(temperatures, prior, 
	label = nothing, xlabel = "temperature", ylabel = "prior")

# ╔═╡ 0a0ab47c-0d61-11eb-324b-c5b2c1e91d22
md"""
## Model definition

We define a literal listener, a speaker and a pragmatic listener.
"""

# ╔═╡ d4a54716-0d5b-11eb-0a16-753470a2251a
function literal_listener(degree, message, θ)
	if degree < θ
		0.0
	else
		prior(degree) / prior_range(θ, last(temperatures))
	end
end

# ╔═╡ d6582570-0d5d-11eb-28f0-ffb9703ffdc6
function cost(message)
	message != "null" ? 2 : 0
end

# ╔═╡ 83cde2ba-0d5d-11eb-3a96-957db0095676
function utility(degree, message, θ)
	log(literal_listener(degree, message, θ)) - cost(message)
end

# ╔═╡ 36206f76-0d5e-11eb-1a6f-a9df99c1a543
function speaker(degree, message, θs, λ)
	u(m) = exp(λ * utility(degree, m, θs[m]))
	
	u(message) / sum(u.(messages))
end

# ╔═╡ 9273de26-0d5f-11eb-00ab-09d6d96b3142
function listener(degree, message, λ)
	not_normalised(d) = let
		speaker_given_θ(θ) = let
			θs = Dict(m => (m == "null" ? first(temperatures) : θ) for m in messages)
			speaker(d, message, θs, λ)
		end
	
		prior(d) * sum(map(speaker_given_θ, temperatures))
	end
	
	not_normalised(degree) / sum(not_normalised.(temperatures))
end

# ╔═╡ 9f05e130-0d72-11eb-065f-0943c6ca045c
function listener_expectation(message, λ)
	posteriors = map(t -> listener(t, message, λ), temperatures)
	sum(temperatures .* posteriors) / sum(posteriors)
end

# ╔═╡ 7a2ac514-0d5f-11eb-30b0-57e7dde56430
md"""
# Testing
"""

# ╔═╡ b554e202-0d6e-11eb-10b0-f5823d50597f
ex_θs =  Dict(m => (m == "null" ? first(temperatures) : 20) for m in messages)

# ╔═╡ ef00da32-0d5e-11eb-35f3-55d363c429ad
λ = 2

# ╔═╡ fcafddee-0d6e-11eb-3bd9-3b062c58d013
let
	p = plot(title="literal listener", xlabel = "temperature")
	
	for m in messages
		plot!(p, temperatures, t -> literal_listener(t, m, ex_θs[m]), label = m)
	end
	
	p
end

# ╔═╡ c3cf80a2-0d5e-11eb-2baa-39a2c31ae79e
let
	p = plot(title="utility", xlabel = "temperature")
	
	for m in messages
		plot!(p, temperatures, t -> utility(t, m, ex_θs[m]), label = m)
	end
	
	p
end

# ╔═╡ 36bde40e-0d6f-11eb-211c-c5650d166c83
let
	p = plot(title="speaker", xlabel = "temperature")
	
	for m in messages
		plot!(p, temperatures, t -> speaker(t, m, ex_θs, λ), label = m)
	end
	
	p
end

# ╔═╡ 47e02ce2-0d6f-11eb-0565-efbb0d9a9473
let
	p = plot(title="listener", xlabel = "temperature")
	
	for m in messages
		plot!(p, temperatures, t -> listener(t, m, λ), label = m)
	end
	
	p
end

# ╔═╡ cfe8f3e6-0d72-11eb-3b3d-7329a00041b2
listener_expectation("warm", λ)

# ╔═╡ ea5828c8-0d72-11eb-205c-b3a9f77cc52c
listener_expectation("null", λ)

# ╔═╡ 9af6ba26-0e24-11eb-002b-171800077f76
md"""
Module imports:
"""

# ╔═╡ Cell order:
# ╟─1d6b6f7a-0d61-11eb-288b-911cc4f27369
# ╠═5d8e8c22-0d5c-11eb-1398-db1ee99ce9d1
# ╟─6ed46d94-0d61-11eb-08cd-57c807d997d1
# ╠═65aa2d94-0d5c-11eb-3e91-59f2d7d9b912
# ╟─a0a4b8de-0d60-11eb-275a-3106e8fd8afe
# ╠═b26a8ad8-0d42-11eb-2f59-7170495b6e55
# ╠═c239f65e-0d5f-11eb-0c7c-e1ad78c7993b
# ╠═f142fcf2-0d5f-11eb-093b-ff8db091db27
# ╠═a0c73006-0e20-11eb-3592-3b0206ad76c2
# ╟─0a0ab47c-0d61-11eb-324b-c5b2c1e91d22
# ╠═d4a54716-0d5b-11eb-0a16-753470a2251a
# ╠═36206f76-0d5e-11eb-1a6f-a9df99c1a543
# ╠═83cde2ba-0d5d-11eb-3a96-957db0095676
# ╠═d6582570-0d5d-11eb-28f0-ffb9703ffdc6
# ╠═9273de26-0d5f-11eb-00ab-09d6d96b3142
# ╠═9f05e130-0d72-11eb-065f-0943c6ca045c
# ╟─7a2ac514-0d5f-11eb-30b0-57e7dde56430
# ╠═b554e202-0d6e-11eb-10b0-f5823d50597f
# ╠═ef00da32-0d5e-11eb-35f3-55d363c429ad
# ╠═fcafddee-0d6e-11eb-3bd9-3b062c58d013
# ╠═c3cf80a2-0d5e-11eb-2baa-39a2c31ae79e
# ╠═36bde40e-0d6f-11eb-211c-c5650d166c83
# ╠═47e02ce2-0d6f-11eb-0565-efbb0d9a9473
# ╠═cfe8f3e6-0d72-11eb-3b3d-7329a00041b2
# ╠═ea5828c8-0d72-11eb-205c-b3a9f77cc52c
# ╟─9af6ba26-0e24-11eb-002b-171800077f76
# ╠═9ba90dda-0d42-11eb-2786-894bf5d128e9
# ╠═2d3a1750-0d64-11eb-2444-835bdf4982b2
