### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ 62826456-0e24-11eb-0d2a-09903f93b9ae
using Distributions, Statistics

# ╔═╡ d66e4a9e-0e27-11eb-0855-8b8d61509c2e
using Plots

# ╔═╡ d2e0127a-0e24-11eb-3689-b1054d292337
temperatures = -10:50

# ╔═╡ da20627e-0e24-11eb-1017-ff861a913adb
messages = ["null", "pleasantly", "horribly"]

# ╔═╡ 50676f46-0e24-11eb-2fda-831bf85743d0
md"""
## Prior distribution of temperatures
"""

# ╔═╡ 5fe5b40a-0e24-11eb-1f44-2f2458172240
prior_temp = Normal(16.962, 7.688)

# ╔═╡ 6a9854dc-0e24-11eb-13ed-cdfc6eb9cd76
prior(degree) = pdf(prior_temp, degree)

# ╔═╡ 70679872-0e24-11eb-157c-9fafc1e38c93
prior_range(lower, upper) = cdf(prior_temp, upper + 1) - cdf(prior_temp, lower)

# ╔═╡ 471832c2-0e24-11eb-0476-c1276d2e16b7
md"""
## Quality of temperatures
"""

# ╔═╡ 99d0bd14-0e23-11eb-0930-17f8f2dd2d33
function quality(T; T_optimal = 25)
	scale = max(T_optimal - first(temperatures), last(temperatures) - T_optimal)
	cos(π * (T - T_optimal) / scale)
end

# ╔═╡ efdd9118-0e24-11eb-05e9-b718b273943b
function increasing_quality(T; T_optimal = 25)
	T <= T_optimal
end

# ╔═╡ 0e0653c8-0e25-11eb-3a7d-4300a6471c4a
function decreasing_quality(T; T_optimal = 25)
	T >= T_optimal
end

# ╔═╡ a5311dbe-0e25-11eb-3e6f-a30be3644017
md"""
## Valence of messages
"""

# ╔═╡ fdd381be-0e25-11eb-0690-dde696775902
function valence(message)
	valence_data = Dict("pleasantly" => 0.939, "horribly" => 0.071)
	return valence_data[message]
end

# ╔═╡ 83f443f0-0e29-11eb-0edb-b9851ffb95a1
θ_q_range = 0:0.025:1

# ╔═╡ 863bc824-0e24-11eb-244c-c5c2ceacf103
md"""
## Model

The significant adaptation from a standard RSA model is in the literal listener.

Normally, the literal listener would assume that a message $m$ is true for a temperature $t$ if 

$t > \theta_T$

where $\theta$ is a threshold temperature.

In the statement _Today is pleasantly warm_, the value of the threshold $\theta_T$ is determined by the use of _pleasantly_. This is derived as follows.

_Pleasant_ is a vague expression in itself: a temperature $t$ is pleasant if

$quality(t) > θ_Q$

Here, $\theta_Q$ is also a threshold, but it is a degree of quality, not temperature. 

I assume that _Today is pleasantly warm_ means something like _Today is so warm that it is pleasant_, or _Today is warm enough to be pleassant_. That is, today should at least be as warm as the coldest temperature that is still pleasant.

$t > \min \{t | quality(t) > θ_Q \}$

For reasons I will explain in my paper, I add a second condition to get a sort of local implication about pleasantness. A suitable threshold $\theta_T$ should not only be pleasant, but the derivative of the quality function should be increasing. Hence, we get

$t > \min \{t | quality(t) > θ_Q \wedge quality'(t) \geq 0 \}$

For a negative expression like _horrible_, we get

$t > \min \{t | quality(t) < θ_Q \wedge quality'(t) \leq 0 \}$
"""

# ╔═╡ 2e55a99a-0e24-11eb-1d61-3f30f5c3daf7
function literal_listener(T, message, θ_q)
	if message == "null"
		prior(T) / prior_range(first(temperatures), last(temperatures))
	else
		val = valence(message)
		requirement = if val >= 0.5 
			T -> quality(T) >= θ_q && increasing_quality(T)
		else
			T -> quality(T) <= θ_q && decreasing_quality(T)
		end
		θ_T = first(filter(requirement, temperatures))
		
		if T >= θ_T
			prior(T) / prior_range(θ_T, last(temperatures))
		else
			0
		end
	end
end

# ╔═╡ 28d7735a-0e28-11eb-29f3-51bd858e119c
function cost(message)
	0.0
end

# ╔═╡ 679715aa-0e28-11eb-340f-0d094f51202d
function utility(T, message, θ_q)
	log(literal_listener(T, message, θ_q)) - cost(message)
end

# ╔═╡ 7224d3e0-0e28-11eb-3d76-019ac2bfd3e6
function speaker(T, message, θ_qs, λ)
	u(m) = exp(λ * utility(T, m, θ_qs[m]))
	
	u(message) / sum(u.(messages))
end

# ╔═╡ 3fc4f2d0-0e29-11eb-1e99-6b85c118cb3c
function listener(degree, message, λ)
	not_normalised(T) = let
		speaker_given_θ(θ) = let
			θ_qs = Dict(m => θ for m in messages)
			speaker(T, message, θ_qs, λ)
		end
	
		prior(T) * sum(map(speaker_given_θ, θ_q_range))
	end
	
	not_normalised(degree) / sum(not_normalised.(temperatures))
end

# ╔═╡ 92447a22-0e28-11eb-177f-259c76ee3ed0
md"""
## Testing
"""

# ╔═╡ 99dd8134-0e28-11eb-269f-39f66a3e4fd2
θ_qs = Dict(msg => 0.5 for msg in messages)

# ╔═╡ 09e68476-0e29-11eb-3a17-7fb15acd5557
λ = 1

# ╔═╡ b206c2b2-0e27-11eb-1495-71d00a52ca8b
let
	p = plot(title = "literal listener", xlabel = "temperature")
	
	for message in messages
		plot!(p, temperatures, literal_listener.(temperatures, message, 0.5), 
			label = message)
	end
	p
end

# ╔═╡ 8b11a0f4-0e28-11eb-0282-cbf4b0e2c684
let
	p = plot(title = "utility", xlabel = "temperature")
	
	for message in messages
		plot!(p, temperatures, utility.(temperatures, message, 0.5), 
			label = message)
	end
	p
end

# ╔═╡ e5ca9f8c-0e28-11eb-07ef-75125c9819d0
let
	p = plot(title = "speaker", xlabel = "temperature")
	
	for message in messages
		posteriors = map(temperatures) do T
			speaker(T, message, θ_qs, λ)
		end
		plot!(p, temperatures, posteriors, 
			label = message)
	end
	p
end

# ╔═╡ 50f6eeac-0e29-11eb-2827-b1929fd21330
let
	p = plot(title = "listener", xlabel = "temperature")
	
	for message in messages
		plot!(p, temperatures, listener.(temperatures, message, λ), 
			label = message)
	end
	p
end

# ╔═╡ 28829952-0e28-11eb-294e-35639237f641
md"Package imports:"

# ╔═╡ Cell order:
# ╠═d2e0127a-0e24-11eb-3689-b1054d292337
# ╠═da20627e-0e24-11eb-1017-ff861a913adb
# ╟─50676f46-0e24-11eb-2fda-831bf85743d0
# ╠═5fe5b40a-0e24-11eb-1f44-2f2458172240
# ╠═6a9854dc-0e24-11eb-13ed-cdfc6eb9cd76
# ╠═70679872-0e24-11eb-157c-9fafc1e38c93
# ╟─471832c2-0e24-11eb-0476-c1276d2e16b7
# ╠═99d0bd14-0e23-11eb-0930-17f8f2dd2d33
# ╠═efdd9118-0e24-11eb-05e9-b718b273943b
# ╠═0e0653c8-0e25-11eb-3a7d-4300a6471c4a
# ╟─a5311dbe-0e25-11eb-3e6f-a30be3644017
# ╠═fdd381be-0e25-11eb-0690-dde696775902
# ╠═83f443f0-0e29-11eb-0edb-b9851ffb95a1
# ╟─863bc824-0e24-11eb-244c-c5c2ceacf103
# ╠═2e55a99a-0e24-11eb-1d61-3f30f5c3daf7
# ╠═7224d3e0-0e28-11eb-3d76-019ac2bfd3e6
# ╠═679715aa-0e28-11eb-340f-0d094f51202d
# ╠═28d7735a-0e28-11eb-29f3-51bd858e119c
# ╠═3fc4f2d0-0e29-11eb-1e99-6b85c118cb3c
# ╟─92447a22-0e28-11eb-177f-259c76ee3ed0
# ╠═99dd8134-0e28-11eb-269f-39f66a3e4fd2
# ╠═09e68476-0e29-11eb-3a17-7fb15acd5557
# ╠═b206c2b2-0e27-11eb-1495-71d00a52ca8b
# ╠═8b11a0f4-0e28-11eb-0282-cbf4b0e2c684
# ╠═e5ca9f8c-0e28-11eb-07ef-75125c9819d0
# ╠═50f6eeac-0e29-11eb-2827-b1929fd21330
# ╟─28829952-0e28-11eb-294e-35639237f641
# ╠═62826456-0e24-11eb-0d2a-09903f93b9ae
# ╠═d66e4a9e-0e27-11eb-0855-8b8d61509c2e
