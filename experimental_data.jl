### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ 0ec3f042-0d83-11eb-0f57-a1b12e6328cc
using CSV, DataFrames, Statistics

# ╔═╡ 89ac52a2-1460-11eb-2f22-4f8c5a85cfc3
begin
	include("weather.jl")
	include("valence.jl")
end

# ╔═╡ 60afe972-0d82-11eb-3cd1-e12d07d160f7
experiment_path = "./data/experiment.csv"

# ╔═╡ ed0939e8-0e34-11eb-22d6-092f7b09060f
md"## Experiment results"

# ╔═╡ 981153ea-0d82-11eb-0261-8f7023dca851
exp_data = CSV.read(experiment_path, DataFrame)

# ╔═╡ 4905ceba-0d83-11eb-2984-b7e022ec1f65
intensifiers = filter(int -> int != "bare", unique(exp_data.adverb))

# ╔═╡ 6f8673da-0d83-11eb-29e4-bbe1bb7e50c8
function responses(intensifier)
	results = exp_data[exp_data.adverb .== intensifier, :response]
	celcius.(results)
end

# ╔═╡ 69147cae-146f-11eb-240d-15b1e163af3c
function mean_response(intensifier)
	mean ∘ responses(intensifier)
end

# ╔═╡ Cell order:
# ╠═0ec3f042-0d83-11eb-0f57-a1b12e6328cc
# ╠═60afe972-0d82-11eb-3cd1-e12d07d160f7
# ╠═89ac52a2-1460-11eb-2f22-4f8c5a85cfc3
# ╟─ed0939e8-0e34-11eb-22d6-092f7b09060f
# ╠═981153ea-0d82-11eb-0261-8f7023dca851
# ╠═4905ceba-0d83-11eb-2984-b7e022ec1f65
# ╠═6f8673da-0d83-11eb-29e4-bbe1bb7e50c8
# ╠═69147cae-146f-11eb-240d-15b1e163af3c
