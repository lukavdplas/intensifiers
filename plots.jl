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

# ╔═╡ 94c8991c-1455-11eb-3bb5-057745fc8e54
using DataFrames, Plots, Distributions

# ╔═╡ 8eae5e92-1456-11eb-3479-0da86a710339
begin
	include("weather.jl")
	include("quality.jl")
	include("valence.jl")
	include("experimental_data.jl")
	include("bleached_model.jl")
end

# ╔═╡ 2d2ad394-146c-11eb-2abb-fd705dfb96af
md"""
# Plots

This notebook contains most of the plots that end up in the final paper.

The exception are the plots for the unbleached model, because it has several functions for which the names overlap with the bleached model, so I don't want to import them simultaneously.
"""

# ╔═╡ c7ec7196-1456-11eb-174a-6361cf2c5e44
temperatures = -10:50

# ╔═╡ 35ef1ff8-156b-11eb-155b-a97bb81c3705
md"""
Use checkbox below the save plots as they are updated.

(Note: does not work in static version.)
"""

# ╔═╡ 4418ac4a-1569-11eb-27b5-ab2ce0ad72c7
@bind save_plots html"<input type=checkbox> Auto-save plots"

# ╔═╡ 6d59e330-1569-11eb-3ccc-f3d7bf834822
function save_plot(p, name)
	folder = "./figures/"
	extension = ".pdf"
	if save_plots
		savefig(p, folder * name * extension )
	end
end

# ╔═╡ 74abc150-1463-11eb-2d5f-63a0725ebd3d
md"""
## Temperature distribution

The histogram of temperatures in New York in spring
"""

# ╔═╡ c3d99e5c-1463-11eb-0b97-ab510369fddf
let
	p = histogram(max_temperatures, 
		bins = 20, normalize=true,
		xlabel = "temperature", ylabel = "frequency", legend = nothing, 
		xlims = (-10, 50),
		palette = :seaborn_muted)
	
	save_plot(p, "temperature_histogram")
	p
end

# ╔═╡ 8bc168d2-1566-11eb-3188-7fe10fabc249
md"The fitted probability distribution"

# ╔═╡ cf75635c-1463-11eb-28df-91ebf68347c9
let
	p = plot(temperatures, prior, 
		xlabel = "temperature", ylabel = "P", legend = nothing, 
		palette = :seaborn_muted, color = 2, lw = 3)
	
	save_plot(p, "temperature_distribution")
	p
end

# ╔═╡ 6d19deb6-1456-11eb-0b1d-13fd70f90fb7
md"""
## Temperature quality

The quality function, given an optimal temperature:
"""

# ╔═╡ cfdc7e1c-1456-11eb-2382-df189721fa46
md"""
Optimal temperature:

$(@bind t_optimal html"<input type=range min=-10 max=50 value=25>")

(Note: slider does not work in static export)
"""

# ╔═╡ fe9fb5b4-1568-11eb-3141-09c71ab15c76
md"Optimal temperature: $(t_optimal)°C"

# ╔═╡ d51b068c-1456-11eb-0771-15439bbac1cc
let
	p = plot(temperatures, quality.(temperatures, t_optimal = t_optimal), 
		label=nothing, xlabel = "temperature", ylabel = "quality",
		palette = :seaborn_muted, color = 2, lw = 3)
	
	save_plot(p, "quality_optimum_$(t_optimal)")
	p
end

# ╔═╡ eb7abc5e-1566-11eb-267e-afea7bd785f3
md"""
The probability distribution of the optimal temperature:
"""

# ╔═╡ f7870108-1566-11eb-3d7f-e572f4806934
let
	p = plot(temperatures, optimum_prior,
		label=nothing, xlabel = "optimal temperature", ylabel = "P",
		palette = :seaborn_muted, color = 2, lw = 3)
	
	save_plot(p, "optimal_t_distribution")
	p
end

# ╔═╡ 5d525094-146f-11eb-376f-5576a6a074c9
md"""
## Experimental data

Aggregated responses from the experiment.
"""

# ╔═╡ b79ccb92-146f-11eb-3a25-d714369df5ca
response_data = DataFrame(
	"intensifier" => intensifiers, 
	"valence" => valence.(intensifiers), 
	"mean_response" => mean_response.(intensifiers),
	"std_response" => (std ∘ responses).(intensifiers))

# ╔═╡ 60c65348-1568-11eb-1c27-5fc7dbd9121c
md"""
Mean response compared to valence.
""" 

# ╔═╡ bfd4f3ae-146f-11eb-36cb-9d8e97cab2ba
let
	p = scatter(response_data.valence, response_data.mean_response, 
		#yerror = response_data.std_response,
		label = nothing, xlabel = "valence", ylabel = "mean response (°C)",
		palette = :seaborn_muted)
	
	save_plot(p, "responses")
	p
end

# ╔═╡ 53cf8baa-1536-11eb-2b5b-9112220d72cb
md"""
## Bleached model

The model requires the parameters λ and γ.
"""

# ╔═╡ 0cf929e6-1538-11eb-30ab-a7cc27f8260c
λ = 3.991

# ╔═╡ d3af2f3c-1537-11eb-0769-01617b548a8c
γ = 1.308

# ╔═╡ 164ef02a-1538-11eb-1111-5b996712e670
predictor = model(λ, γ)

# ╔═╡ 5063c734-1538-11eb-17ea-4d85261c2cfa
bleached_data = let
	table = response_data[:, ["intensifier", "valence", "mean_response"]]
	table.prediction = predictor.(table.intensifier)
	sort(table, "valence")
end

# ╔═╡ b72cf078-1538-11eb-0af1-5dbc36b8b7d8
let
	p = plot(xlabel = "valence", ylabel = "temperature", palette = :seaborn_muted)
	scatter!(p, bleached_data.valence, bleached_data.mean_response, 
		label = "experimental results")
	plot!(p, bleached_data.valence, bleached_data.prediction, 
		label = "model", lw=3)
	
	save_plot(p, "experiments_vs_bleached")
	p
end

# ╔═╡ 85b42b22-153d-11eb-1ccd-3de4923182fd
example_messages = ["fairly", "terribly"]

# ╔═╡ caee5958-156a-11eb-25af-2bd7a61092c8
example_posteriors = Dict(
	m => listener.(temperatures, m, λ, γ) for m in example_messages)

# ╔═╡ 57ba22e6-153d-11eb-1e82-0b253b60d7f4
let
	p = plot(xlabel = "temperature", ylabel = "P", palette = :seaborn_muted6)
	
	plot!(p, temperatures, prior.(temperatures), label = "prior", lw = 3)
	
	for message in example_messages
		plot!(p, temperatures, example_posteriors[message], 
			label = message, lw = 3)
	end
	
	save_plot(p, "bleached_listener")
	p
end

# ╔═╡ Cell order:
# ╟─2d2ad394-146c-11eb-2abb-fd705dfb96af
# ╠═94c8991c-1455-11eb-3bb5-057745fc8e54
# ╠═8eae5e92-1456-11eb-3479-0da86a710339
# ╠═c7ec7196-1456-11eb-174a-6361cf2c5e44
# ╟─35ef1ff8-156b-11eb-155b-a97bb81c3705
# ╟─4418ac4a-1569-11eb-27b5-ab2ce0ad72c7
# ╠═6d59e330-1569-11eb-3ccc-f3d7bf834822
# ╟─74abc150-1463-11eb-2d5f-63a0725ebd3d
# ╠═c3d99e5c-1463-11eb-0b97-ab510369fddf
# ╟─8bc168d2-1566-11eb-3188-7fe10fabc249
# ╠═cf75635c-1463-11eb-28df-91ebf68347c9
# ╟─6d19deb6-1456-11eb-0b1d-13fd70f90fb7
# ╟─cfdc7e1c-1456-11eb-2382-df189721fa46
# ╟─fe9fb5b4-1568-11eb-3141-09c71ab15c76
# ╠═d51b068c-1456-11eb-0771-15439bbac1cc
# ╟─eb7abc5e-1566-11eb-267e-afea7bd785f3
# ╠═f7870108-1566-11eb-3d7f-e572f4806934
# ╟─5d525094-146f-11eb-376f-5576a6a074c9
# ╠═b79ccb92-146f-11eb-3a25-d714369df5ca
# ╟─60c65348-1568-11eb-1c27-5fc7dbd9121c
# ╠═bfd4f3ae-146f-11eb-36cb-9d8e97cab2ba
# ╟─53cf8baa-1536-11eb-2b5b-9112220d72cb
# ╠═0cf929e6-1538-11eb-30ab-a7cc27f8260c
# ╠═d3af2f3c-1537-11eb-0769-01617b548a8c
# ╠═164ef02a-1538-11eb-1111-5b996712e670
# ╠═5063c734-1538-11eb-17ea-4d85261c2cfa
# ╠═b72cf078-1538-11eb-0af1-5dbc36b8b7d8
# ╠═85b42b22-153d-11eb-1ccd-3de4923182fd
# ╠═caee5958-156a-11eb-25af-2bd7a61092c8
# ╠═57ba22e6-153d-11eb-1e82-0b253b60d7f4
