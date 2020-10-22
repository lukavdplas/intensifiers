### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ 31ac48c8-1460-11eb-1fb5-33e0f55cbed9
using DataFrames, CSV

# ╔═╡ f3e7d480-145f-11eb-1b95-8909c438d4b1
md"""
# Valence

We import the data on intensifiers and define a function `valence` that will be used in the models.
"""

# ╔═╡ 282616da-1460-11eb-0dcf-4306cb49e696
valence_path = "./data/valenceforexp.csv"

# ╔═╡ 3b4e99a8-1460-11eb-1760-61961068fbd3
valence_data = CSV.read(valence_path, DataFrame)

# ╔═╡ deb39940-1460-11eb-285d-43f93fc08395
valence_dict = let
	value(intensifier) = let
		intensifier_data = valence_data[valence_data.adverb .== intensifier, :]
		first(intensifier_data.Valence)
	end
	
	Dict(intensifier => value(intensifier) for intensifier in valence_data.adverb)
end

# ╔═╡ 4f0b8014-1460-11eb-3e16-bf4f15328377
function valence(intensifier)
	valence_dict[intensifier]
end

# ╔═╡ Cell order:
# ╟─f3e7d480-145f-11eb-1b95-8909c438d4b1
# ╠═31ac48c8-1460-11eb-1fb5-33e0f55cbed9
# ╠═282616da-1460-11eb-0dcf-4306cb49e696
# ╠═3b4e99a8-1460-11eb-1760-61961068fbd3
# ╠═deb39940-1460-11eb-285d-43f93fc08395
# ╠═4f0b8014-1460-11eb-3e16-bf4f15328377
