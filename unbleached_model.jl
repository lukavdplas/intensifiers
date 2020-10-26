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

I still have to complete the documentation here.

### The literal listener

The literal listener function uses a quality threshold, but is otherwise fairly standard.

"""

# ╔═╡ 3017d016-17d2-11eb-1eb9-b77c5f7e76d8
md"""However, their semantics function looks wildly different.

I use the shortcut that the truth value for the empty message is always _true_.

For the vague message, we sum out over the different optimal temperatures. We take the probability of a temperature being the optimum, and pass it on to a more specific semantics function, which uses the optimum as well.
"""

# ╔═╡ 8665d558-145d-11eb-0516-ed214a73986d
function semantics(t, message, θ_q)
	if message == "null"
		1
	else
		t_opt_domain = 15:35 #small t_opt domain for speed
		values = map(t_opt_domain) do t_optimal
			semantics(t, message, θ_q, t_optimal) * optimum_prior(t_optimal)
		end
		sum(values)
	end
end

# ╔═╡ 8c7e712a-17d2-11eb-0915-4b00247ccf78
md"""
For postive messages: t must be over the quality threshold and be of increasing quality.

For negative messages: t must be under the quality threshold and be of decreasing quality.
"""

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
md"The utility function does not use a cost function for the sake of simplicity."

# ╔═╡ 679715aa-0e28-11eb-340f-0d094f51202d
function utility(T, message, θ_q)
	log(literal_listener(T, message, θ_q))
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

For the pragmatic listener, we calculate all degrees at the same time because it speeds up normalisation considerably.

The pragmatic listener sums out all possible thresholds, but these are sampled from the quality domain $[0,1]$.
"""

# ╔═╡ f78e5b2e-0fc1-11eb-0f8e-bbaef07de1cf
function normalise(values)
	values ./ sum(values)
end

# ╔═╡ b34727c4-17d3-11eb-237f-cbe533fb3636
md"""
We define the quality measures that we will sum out over. This is a continuous set, so ideally, you would either integrate analytically (no), or take the image of $quality(\textbf{T} \times \textbf{T})$ as a finite set that you can iterate over. That way, you would include all possible values of $quality(t, t_{opt})$.

Even with the limited range of $T_{opt}$ that I implemented, these are too many values, so instead I just take a small sample. 
"""

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

# ╔═╡ 25eabaaa-17cf-11eb-396a-5194a4d30a1e
@bind save_plot html"<input type=checkbox> Save plot"

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
	p = plot(xlabel = "temperature", ylabel = "P", palette = :seaborn_muted6)
	
	plot!(p, temperatures, prior.(temperatures), label = "prior", lw = 3)
	
	for i in 1:length(messages)
		message = messages[i]
		result = results[i]
		plot!(p, temperatures, result, 
			label = message, lw = 3)
	end
	
	#save
	if run_test && save_plot
		savefig(p, "./figures/unbleached_listener.pdf" )
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
# ╟─3017d016-17d2-11eb-1eb9-b77c5f7e76d8
# ╠═8665d558-145d-11eb-0516-ed214a73986d
# ╟─8c7e712a-17d2-11eb-0915-4b00247ccf78
# ╠═e22b9c32-0fbd-11eb-228d-85a502f80b29
# ╟─3cf38e04-145f-11eb-0426-31d2a4ebdfe8
# ╠═7224d3e0-0e28-11eb-3d76-019ac2bfd3e6
# ╟─6ed04904-1544-11eb-2791-1d35b61eadb6
# ╠═679715aa-0e28-11eb-340f-0d094f51202d
# ╟─486632e6-145f-11eb-145d-5f4b6167d7d9
# ╠═4f9615c0-0fc0-11eb-266a-8fc45ddddd5d
# ╠═f78e5b2e-0fc1-11eb-0f8e-bbaef07de1cf
# ╟─b34727c4-17d3-11eb-237f-cbe533fb3636
# ╠═83f443f0-0e29-11eb-0edb-b9851ffb95a1
# ╟─92447a22-0e28-11eb-177f-259c76ee3ed0
# ╟─d425165a-146c-11eb-3d8b-17265ad94d6a
# ╟─25eabaaa-17cf-11eb-396a-5194a4d30a1e
# ╠═09e68476-0e29-11eb-3a17-7fb15acd5557
# ╠═da20627e-0e24-11eb-1017-ff861a913adb
# ╠═f2f8a13c-146c-11eb-18d6-4fc367da5f50
# ╠═50f6eeac-0e29-11eb-2827-b1929fd21330
# ╟─28829952-0e28-11eb-294e-35639237f641
# ╠═62826456-0e24-11eb-0d2a-09903f93b9ae
# ╠═d66e4a9e-0e27-11eb-0855-8b8d61509c2e
