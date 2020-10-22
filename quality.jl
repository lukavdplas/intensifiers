### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ 5e68b950-1456-11eb-19b6-f3a1451888cf
using Distributions

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

I am roughly basing my function [this paper](https://arxiv.org/ftp/arxiv/papers/1709/1709.00071.pdf). I decided to use a cosine function to get the curvature I wanted. I scale the function horizontally so that the edges of the domain are both global minimal for the quality.

"""

# ╔═╡ 1602b64c-0e1c-11eb-1a4f-95d1cbd61452
function quality(t; t_optimal = 25)
	scale = if t < t_optimal
		t_optimal - first(temperatures)
		
	else
		last(temperatures) - t_optimal
	end
	cos(π * (t - t_optimal) / scale)
end

# ╔═╡ ef4f1de6-1457-11eb-3891-e5115211eb67
md"""
As mentioned, we will use some information about the derivative. Note that $quality$ is defined piecewise, but is smooth and continuous, so the gradient is still defined for every point in the domain.

We will only use information on whether the $quality$ is increasing or decreasing on a point $t$, so it is faster to not use the actual gradient. Given the restrictions we put on $quality$, we can simply say:
"""

# ╔═╡ 69f194e8-1458-11eb-1286-bf3642a440bd
function increasing_quality(t; t_optimal = 25)
	t <= t_optimal
end

# ╔═╡ 6f919998-1458-11eb-0682-717915707ab1
function decreasing_quality(t; t_optimal = 25)
	t >= t_optimal
end

# ╔═╡ e2e797ba-1455-11eb-13c8-e17a7439a353
md"""
There is some variation in what is considered an optimal temperature. I assume that the optimal temperature is normally distributed.
"""

# ╔═╡ 8ab84bce-1456-11eb-0a8d-4f141574195d
t_opt_dist = Normal(25, 2.5)

# ╔═╡ d812ebe4-1457-11eb-2874-1d9e4bed8c6d
optimum_prior(t) = pdf(t_opt_dist, t)

# ╔═╡ Cell order:
# ╟─285a22da-0e17-11eb-0683-7fb7298050ac
# ╟─e21058fa-0e1e-11eb-229d-03148e523f6d
# ╠═1602b64c-0e1c-11eb-1a4f-95d1cbd61452
# ╟─ef4f1de6-1457-11eb-3891-e5115211eb67
# ╠═69f194e8-1458-11eb-1286-bf3642a440bd
# ╠═6f919998-1458-11eb-0682-717915707ab1
# ╟─e2e797ba-1455-11eb-13c8-e17a7439a353
# ╠═5e68b950-1456-11eb-19b6-f3a1451888cf
# ╠═8ab84bce-1456-11eb-0a8d-4f141574195d
# ╠═d812ebe4-1457-11eb-2874-1d9e4bed8c6d
