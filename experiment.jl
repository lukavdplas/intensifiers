### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ 0ec3f042-0d83-11eb-0f57-a1b12e6328cc
using CSV, DataFrames, Statistics

# ╔═╡ d12aea32-0d83-11eb-238d-89bef7c0bedc
using Plots

# ╔═╡ ed0939e8-0e34-11eb-22d6-092f7b09060f
md"## Experiment results"

# ╔═╡ b27eefb2-0d82-11eb-3a4c-8b80a3f37382
function celcius(T)
	(T - 32) * 5/9
end

# ╔═╡ 845a6716-0d89-11eb-1e2b-cfe0cbba2c1f
function exclude_outliers(points)
	μ = mean(points)
	σ = std(points)
	filter(points) do point
		abs((point - μ) / σ) <= 2
	end
end

# ╔═╡ f40661ae-0e34-11eb-35cf-15edd1baeaa4
md"## Valence data"

# ╔═╡ 01642522-0e35-11eb-0bdf-c587e25b21fa
md"## Plot"

# ╔═╡ dbd4773a-0e34-11eb-0f5d-236205385779
md"Imports and pathnames:"

# ╔═╡ 587d57d4-0d86-11eb-23e2-e99e8b9b8409
data_path = "./data/"

# ╔═╡ 60afe972-0d82-11eb-3cd1-e12d07d160f7
experiment_path = data_path * "experiment.csv"

# ╔═╡ 981153ea-0d82-11eb-0261-8f7023dca851
exp_data = CSV.read(experiment_path, DataFrame)

# ╔═╡ 4905ceba-0d83-11eb-2984-b7e022ec1f65
intensifiers = unique(exp_data.adverb)

# ╔═╡ 6f8673da-0d83-11eb-29e4-bbe1bb7e50c8
function responses(intensifier; convert = true)
	results = exp_data[exp_data.adverb .== intensifier, :response]
	#results = exclude_outliers(results)
	if convert
		celcius.(results)
	else
		results
	end
end

# ╔═╡ 56fc5c34-0d86-11eb-3efd-e71edd8e7578
valence_path = data_path * "valenceforexp.csv"

# ╔═╡ 7440f930-0d86-11eb-3a77-01c95e1bcb31
valence_data = CSV.read(valence_path, DataFrame)

# ╔═╡ a57c7f56-0d86-11eb-1b09-bd0bac9b3e29
function valence(intensifier)
	if intensifier == "bare"
		return 0.5
	else
		intensifier_data = valence_data[valence_data.adverb .== intensifier, :]
		return first(intensifier_data.Valence)
	end
end

# ╔═╡ 7e199af8-0d88-11eb-2385-67be3597036c
plot_data = DataFrame(
	"intensifier" => intensifiers, 
	"valence" => valence.(intensifiers), 
	"temperature" => (mean ∘ responses).(intensifiers),
	"std" => (std ∘ responses).(intensifiers))

# ╔═╡ c9538c10-0d88-11eb-23e2-c38d6ceb4ddd
scatter(plot_data.valence, plot_data.temperature, 
	#yerror = plot_data.std,
	#series_annotations = Plots.text.(plot_data.intensifier, :bottom, 8),
	label = nothing, xlabel = "valence", ylabel = "mean response (°C)")

# ╔═╡ Cell order:
# ╟─ed0939e8-0e34-11eb-22d6-092f7b09060f
# ╠═981153ea-0d82-11eb-0261-8f7023dca851
# ╠═4905ceba-0d83-11eb-2984-b7e022ec1f65
# ╠═b27eefb2-0d82-11eb-3a4c-8b80a3f37382
# ╠═845a6716-0d89-11eb-1e2b-cfe0cbba2c1f
# ╠═6f8673da-0d83-11eb-29e4-bbe1bb7e50c8
# ╟─f40661ae-0e34-11eb-35cf-15edd1baeaa4
# ╠═7440f930-0d86-11eb-3a77-01c95e1bcb31
# ╠═a57c7f56-0d86-11eb-1b09-bd0bac9b3e29
# ╟─01642522-0e35-11eb-0bdf-c587e25b21fa
# ╠═7e199af8-0d88-11eb-2385-67be3597036c
# ╠═c9538c10-0d88-11eb-23e2-c38d6ceb4ddd
# ╟─dbd4773a-0e34-11eb-0f5d-236205385779
# ╠═0ec3f042-0d83-11eb-0f57-a1b12e6328cc
# ╠═d12aea32-0d83-11eb-238d-89bef7c0bedc
# ╠═587d57d4-0d86-11eb-23e2-e99e8b9b8409
# ╠═60afe972-0d82-11eb-3cd1-e12d07d160f7
# ╠═56fc5c34-0d86-11eb-3efd-e71edd8e7578
