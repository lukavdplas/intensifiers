### A Pluto.jl notebook ###
# v0.12.3

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

# ╔═╡ 4699f9c6-0e17-11eb-20a8-991c7639a5ac
using Plots

# ╔═╡ 285a22da-0e17-11eb-0683-7fb7298050ac
md"""
# Weather quality

We want to define a function that determines the quality (i.e. subjective "goodness") of a temperature.

We use a domain of temperatures $T = [-10, 50]$, and define $quality: T \rightarrow \mathbb{R}$

Some desired properties:

There must exist a temperature $t_{opt}$ with $\min(T) < t_{opt} < \max(T)$, such that $quality$ is monotone increasing on $[\min(T) , t_{opt}]$, and monotone decreasing on $[t_{opt}, \max(T)]$. 

More strictly, $quality(t_{opt}) > quality(\min(T))$, and $quality(t_{opt}) > quality(\max(T))$. (In other words, $quality$ cannot be constant.)

These two properties ensure the concept of double-sided excess, and the existence of a "goldilocks zone".

Furthermore, the value of $\frac{\delta \, quality(t)}{\delta \, t}$ must be defined for all $t \in T$. This is not strictly necessary, but will be convenient for the definition of the wider model.
"""

# ╔═╡ e21058fa-0e1e-11eb-229d-03148e523f6d
md"""
## Implementation

I am roughly basing my function [this paper](https://arxiv.org/ftp/arxiv/papers/1709/1709.00071.pdf). I decided to use a cosine function to get the curvature I wanted, where the function is scaled to include at most half a phase within the domain.

The function uses an optimum temperature as a parameter, which I estimate as 25°C
"""

# ╔═╡ 96b69140-0e1f-11eb-2c67-756ef58f1d96
md"""
## Plot
"""

# ╔═╡ 0add64ce-0e1c-11eb-15d7-d9a72989eadb
temperatures = -10:50

# ╔═╡ 1602b64c-0e1c-11eb-1a4f-95d1cbd61452
function quality(T; T_optimal = 25)
	scale = max(T_optimal - first(temperatures), last(temperatures) - T_optimal)
	cos(π * (T - T_optimal) / scale)
end

# ╔═╡ cbe31486-0e1f-11eb-02e0-6b08ca181182
@bind T_optimal html"<input type=range min=-10 max=50 value=25>"

# ╔═╡ e8eb42d8-0e1f-11eb-0f39-f7f983e01fae
md"Optimal temperature: $(T_optimal) °C"

# ╔═╡ 20d8dc7c-0e1c-11eb-178f-8b70e057c1fd
plot(temperatures, quality.(temperatures, T_optimal = T_optimal), 
	label=nothing, xlabel = "temperature", ylabel = "quality")

# ╔═╡ 7531071c-0fa8-11eb-153a-c1e368d9db42
md"""
## One-sided quality functions
"""

# ╔═╡ acd0c320-0fa7-11eb-151a-5198f3a567ab
function warmth_quality(T; T_optimal = 25)
	if T < T_optimal
		1
	else
		quality(T)
	end
end

# ╔═╡ e7b85c78-0fa7-11eb-09e8-11ab24ce5f3a
function cold_quality(T; T_optimal = 25)
	if T > T_optimal
		1
	else
		quality(T)
	end
end

# ╔═╡ d25f02a0-0fa7-11eb-389a-ed231cc697e3
let
	p = plot(xlabel = "temperature", ylabel = "quality")
	plot!(temperatures, warmth_quality.(temperatures, T_optimal = T_optimal),
		label="warmth", linecolor = :red)
	plot!(temperatures, cold_quality.(temperatures, T_optimal = T_optimal),
		label="cold", linecolor = :deepskyblue)
end

# ╔═╡ Cell order:
# ╟─285a22da-0e17-11eb-0683-7fb7298050ac
# ╟─e21058fa-0e1e-11eb-229d-03148e523f6d
# ╠═1602b64c-0e1c-11eb-1a4f-95d1cbd61452
# ╟─96b69140-0e1f-11eb-2c67-756ef58f1d96
# ╠═4699f9c6-0e17-11eb-20a8-991c7639a5ac
# ╠═0add64ce-0e1c-11eb-15d7-d9a72989eadb
# ╠═cbe31486-0e1f-11eb-02e0-6b08ca181182
# ╟─e8eb42d8-0e1f-11eb-0f39-f7f983e01fae
# ╠═20d8dc7c-0e1c-11eb-178f-8b70e057c1fd
# ╟─7531071c-0fa8-11eb-153a-c1e368d9db42
# ╠═acd0c320-0fa7-11eb-151a-5198f3a567ab
# ╠═e7b85c78-0fa7-11eb-09e8-11ab24ce5f3a
# ╠═d25f02a0-0fa7-11eb-389a-ed231cc697e3
