### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ 0ec3f042-0d83-11eb-0f57-a1b12e6328cc
using CSV, DataFrames, Statistics

# ╔═╡ 89ac52a2-1460-11eb-2f22-4f8c5a85cfc3
begin
	include("weather.jl")
end

# ╔═╡ b52538c6-155b-11eb-213e-6d02b7f7d5f2
md"""
# Experimental data

We import the data from the experiment. Subjects give the temperature they expect after hearing _It is [intensifier] warm today_.

We define a function `mean_response` that will give the mean expected temperature for an intensifier.
"""

# ╔═╡ 60afe972-0d82-11eb-3cd1-e12d07d160f7
experiment_path = "./data/experiment.csv"

# ╔═╡ 36000c46-155c-11eb-223d-db7651191b4d
md"
The weather code is imported to get the `celcius` conversion function.
"

# ╔═╡ ed0939e8-0e34-11eb-22d6-092f7b09060f
md"""
## Experiment results

We import the results.
"""

# ╔═╡ 981153ea-0d82-11eb-0261-8f7023dca851
exp_data = CSV.read(experiment_path, DataFrame)

# ╔═╡ 52380922-155c-11eb-2aad-9d20146baeb1
md"""
List of all intensifiers:
"""

# ╔═╡ 4905ceba-0d83-11eb-2984-b7e022ec1f65
intensifiers = filter(int -> int != "bare", unique(exp_data.adverb))

# ╔═╡ 5b78fcb2-155c-11eb-0770-07540790f0d5
md"All responses, and the mean of all responses"

# ╔═╡ 6f8673da-0d83-11eb-29e4-bbe1bb7e50c8
function responses(intensifier)
	results = exp_data[exp_data.adverb .== intensifier, :response]
	celcius.(results)
end

# ╔═╡ 69147cae-146f-11eb-240d-15b1e163af3c
function mean_response(intensifier)
	mean(responses(intensifier))
end

# ╔═╡ Cell order:
# ╟─b52538c6-155b-11eb-213e-6d02b7f7d5f2
# ╠═0ec3f042-0d83-11eb-0f57-a1b12e6328cc
# ╠═60afe972-0d82-11eb-3cd1-e12d07d160f7
# ╟─36000c46-155c-11eb-223d-db7651191b4d
# ╠═89ac52a2-1460-11eb-2f22-4f8c5a85cfc3
# ╟─ed0939e8-0e34-11eb-22d6-092f7b09060f
# ╠═981153ea-0d82-11eb-0261-8f7023dca851
# ╟─52380922-155c-11eb-2aad-9d20146baeb1
# ╠═4905ceba-0d83-11eb-2984-b7e022ec1f65
# ╟─5b78fcb2-155c-11eb-0770-07540790f0d5
# ╠═6f8673da-0d83-11eb-29e4-bbe1bb7e50c8
# ╠═69147cae-146f-11eb-240d-15b1e163af3c
