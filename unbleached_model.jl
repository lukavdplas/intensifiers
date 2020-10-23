### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 62826456-0e24-11eb-0d2a-09903f93b9ae
using Distributions, Statistics

# ╔═╡ d66e4a9e-0e27-11eb-0855-8b8d61509c2e
using Plots

# ╔═╡ c95afa64-1458-11eb-38ac-03ed16acb35d
begin
	include("weather.jl")
	include("quality.jl")
	include("valence.jl")
end

# ╔═╡ 03e99cee-1544-11eb-09d9-374f09f4b77f
md"""
# Unbleached model

The unbleached model uses knowledge about the quality of temperatures to infer the meaning of phrases like _pleasantly warm_ or _horribly warm_.
"""

# ╔═╡ d2e0127a-0e24-11eb-3689-b1054d292337
temperatures = -10:50

# ╔═╡ 471832c2-0e24-11eb-0476-c1276d2e16b7
md"""
## Code import

We import the previous definitions for determining the prior distribution of temperatures, the quality of a temperature, and the valence of an intensifier.
"""

# ╔═╡ 863bc824-0e24-11eb-244c-c5c2ceacf103
md"""
## Model

The significant adaptation from a standard RSA model is in the literal listener.

### The literal listener

Normally, the literal listener would assume that a message $m$ is true for a temperature $t$ if 

$t > \theta_T$

where $\theta$ is a threshold temperature.

In the statement _Today is pleasantly warm_, the value of the threshold $\theta_T$ is determined by the use of _pleasantly_. This is derived as follows.

_Pleasant_ is a vague expression in itself: a temperature $t$ is pleasant if

$quality(t) > \theta_Q$

Here, $\theta_Q$ is also a threshold, but it is a degree of quality, not temperature. 

I assume that _Today is pleasantly warm_ means something like _Today is so warm that it is pleasant_, or _Today is warm enough to be pleassant_. That is, today should at least be as warm as the coldest temperature that is still pleasant.

$t > \min \{t | quality(t) > \theta_Q \}$

For reasons I will explain in my paper, I add a second condition to get a sort of local implication about pleasantness. A suitable threshold $\theta_T$ should not only be pleasant, but the pleasantness must be increasing. That is, the derivative of the quality function must be positive.

$t > \min \{t | quality(t) > \theta_Q \wedge quality'(t) \geq 0 \}$

For a negative expression like _horrible_, we get

$t > \min \{t | quality(t) < \theta_Q \wedge quality'(t) \leq 0 \}$
"""

# ╔═╡ 8665d558-145d-11eb-0516-ed214a73986d
function semantics(t, message, θ_q)
	if message == "null"
		1
	else
		t_opt_domain = 15:35
		values = map(t_opt_domain) do t_optimal
			semantics(t, message, θ_q, t_optimal) * optimum_prior(t_optimal)
		end
		sum(values)
	end
end

# ╔═╡ e22b9c32-0fbd-11eb-228d-85a502f80b29
function semantics(t, message, θ_q, t_optimal)
	requirement(t) = if valence(message) >= 0.5 
		quality(t, t_optimal = t_optimal) >= θ_q && 
			increasing_quality(t, t_optimal = t_optimal)
	else
		quality(t, t_optimal = t_optimal) <= θ_q && 
			decreasing_quality(t, t_optimal = t_optimal)
	end
	
	θ_T = first(filter(requirement, temperatures))

	if t >= θ_T
		1
	else
		0
	end
end

# ╔═╡ 7726ec9c-0fbe-11eb-140f-b3a43dbd0749
function literal_listener(t, message, θ_q)
	value(t) = semantics(t, message, θ_q) * prior(t)
	value(t) / sum(value.(temperatures))
end

# ╔═╡ 3cf38e04-145f-11eb-0426-31d2a4ebdfe8
md"""
### The speaker
"""

# ╔═╡ 6ed04904-1544-11eb-2791-1d35b61eadb6
md"The utility function includes the cost in its definition, for the sake of consistency. 

However, the cost is set to 0."

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
	messages = keys(θ_qs)
	u(m) = exp(λ * utility(T, m, θ_qs[m]))
	
	u(message) / sum(u.(messages))
end

# ╔═╡ 486632e6-145f-11eb-145d-5f4b6167d7d9
md"""
### The pragmatic listener
"""

# ╔═╡ f78e5b2e-0fc1-11eb-0f8e-bbaef07de1cf
function normalise(values)
	values ./ sum(values)
end

# ╔═╡ 83f443f0-0e29-11eb-0edb-b9851ffb95a1
θ_q_range = -1:0.1:1

# ╔═╡ 4f9615c0-0fc0-11eb-266a-8fc45ddddd5d
function listener(degrees::AbstractArray, message, λ)
	not_normalised(T) = let
		speaker_given_θ(θ) = let
			θ_qs = Dict(message => θ, "null" => -1)
			speaker(T, message, θ_qs, λ)
		end
	
		prior(T) * sum(map(speaker_given_θ, θ_q_range))
	end
	
	values = not_normalised.(degrees)
	normalise(values)
end

# ╔═╡ 92447a22-0e28-11eb-177f-259c76ee3ed0
md"""
## Testing
"""

# ╔═╡ d425165a-146c-11eb-3d8b-17265ad94d6a
@bind run_test html"<input type=checkbox> Run test"

# ╔═╡ 09e68476-0e29-11eb-3a17-7fb15acd5557
λ = 2

# ╔═╡ da20627e-0e24-11eb-1017-ff861a913adb
messages = ["pleasantly", "horribly"]

# ╔═╡ f2f8a13c-146c-11eb-18d6-4fc367da5f50
results = map(messages) do message
	if run_test
		listener(temperatures, message, λ)
	else
		zeros(length(temperatures))
	end
end

# ╔═╡ 50f6eeac-0e29-11eb-2827-b1929fd21330
let
	p = plot(title = "listener", xlabel = "temperature", palette = :seaborn_muted6)
	
	plot!(p, temperatures, prior.(temperatures), label = "prior", lw = 3)
	
	for i in 1:length(messages)
		message = messages[i]
		result = results[i]
		plot!(p, temperatures, result, 
			label = message, lw = 3)
	end
	p
end

# ╔═╡ 28829952-0e28-11eb-294e-35639237f641
md"Package imports:"

# ╔═╡ Cell order:
# ╟─03e99cee-1544-11eb-09d9-374f09f4b77f
# ╠═d2e0127a-0e24-11eb-3689-b1054d292337
# ╟─471832c2-0e24-11eb-0476-c1276d2e16b7
# ╠═c95afa64-1458-11eb-38ac-03ed16acb35d
# ╟─863bc824-0e24-11eb-244c-c5c2ceacf103
# ╠═7726ec9c-0fbe-11eb-140f-b3a43dbd0749
# ╠═8665d558-145d-11eb-0516-ed214a73986d
# ╠═e22b9c32-0fbd-11eb-228d-85a502f80b29
# ╟─3cf38e04-145f-11eb-0426-31d2a4ebdfe8
# ╠═7224d3e0-0e28-11eb-3d76-019ac2bfd3e6
# ╟─6ed04904-1544-11eb-2791-1d35b61eadb6
# ╠═679715aa-0e28-11eb-340f-0d094f51202d
# ╠═28d7735a-0e28-11eb-29f3-51bd858e119c
# ╟─486632e6-145f-11eb-145d-5f4b6167d7d9
# ╠═4f9615c0-0fc0-11eb-266a-8fc45ddddd5d
# ╠═f78e5b2e-0fc1-11eb-0f8e-bbaef07de1cf
# ╠═83f443f0-0e29-11eb-0edb-b9851ffb95a1
# ╟─92447a22-0e28-11eb-177f-259c76ee3ed0
# ╟─d425165a-146c-11eb-3d8b-17265ad94d6a
# ╠═09e68476-0e29-11eb-3a17-7fb15acd5557
# ╠═da20627e-0e24-11eb-1017-ff861a913adb
# ╠═f2f8a13c-146c-11eb-18d6-4fc367da5f50
# ╠═50f6eeac-0e29-11eb-2827-b1929fd21330
# ╟─28829952-0e28-11eb-294e-35639237f641
# ╠═62826456-0e24-11eb-0d2a-09903f93b9ae
# ╠═d66e4a9e-0e27-11eb-0855-8b8d61509c2e
