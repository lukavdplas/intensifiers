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
	include("experimental_data.jl")
end

# ╔═╡ 2d2ad394-146c-11eb-2abb-fd705dfb96af
md"""
This notebook contains several plots.

I keep the weather and quality files bare so that I could import them without including a bunch of plots, so here are some visualisations.
"""

# ╔═╡ c7ec7196-1456-11eb-174a-6361cf2c5e44
temperatures = -10:50

# ╔═╡ 74abc150-1463-11eb-2d5f-63a0725ebd3d
md"""
## Temperature distribution
"""

# ╔═╡ c3d99e5c-1463-11eb-0b97-ab510369fddf
histogram(max_temperatures, normalize=true,
	xlabel = "temperature", ylabel = "frequency", legend = nothing, xlims = (-10, 50))

# ╔═╡ cf75635c-1463-11eb-28df-91ebf68347c9
let
	temps = -10:45
	plot(temps, pdf.(prior_temp, temps), 
		xlabel = "temperature", ylabel = "P", legend = nothing)
end

# ╔═╡ 6d19deb6-1456-11eb-0b1d-13fd70f90fb7
md"""
## Temperature quality
"""

# ╔═╡ cfdc7e1c-1456-11eb-2382-df189721fa46
@bind t_optimal html"<input type=range min=-10 max=50 value=25>"

# ╔═╡ d51b068c-1456-11eb-0771-15439bbac1cc
plot(temperatures, quality.(temperatures, t_optimal = t_optimal), 
	label=nothing, xlabel = "temperature", ylabel = "quality")

# ╔═╡ 5d525094-146f-11eb-376f-5576a6a074c9
md"""
## Experimental data
"""

# ╔═╡ b79ccb92-146f-11eb-3a25-d714369df5ca
intensifier_data = DataFrame(
	"intensifier" => intensifiers, 
	"valence" => valence.(intensifiers), 
	"temperature" => (mean ∘ responses).(intensifiers),
	"std" => (std ∘ responses).(intensifiers))

# ╔═╡ bfd4f3ae-146f-11eb-36cb-9d8e97cab2ba
scatter(intensifier_data.valence, intensifier_data.temperature, 
	#yerror = plot_data.std,
	#series_annotations = Plots.text.(plot_data.intensifier, :bottom, 8),
	label = nothing, xlabel = "valence", ylabel = "mean response (°C)")

# ╔═╡ Cell order:
# ╟─2d2ad394-146c-11eb-2abb-fd705dfb96af
# ╠═94c8991c-1455-11eb-3bb5-057745fc8e54
# ╠═8eae5e92-1456-11eb-3479-0da86a710339
# ╠═c7ec7196-1456-11eb-174a-6361cf2c5e44
# ╟─74abc150-1463-11eb-2d5f-63a0725ebd3d
# ╠═c3d99e5c-1463-11eb-0b97-ab510369fddf
# ╠═cf75635c-1463-11eb-28df-91ebf68347c9
# ╟─6d19deb6-1456-11eb-0b1d-13fd70f90fb7
# ╠═cfdc7e1c-1456-11eb-2382-df189721fa46
# ╠═d51b068c-1456-11eb-0771-15439bbac1cc
# ╟─5d525094-146f-11eb-376f-5576a6a074c9
# ╠═b79ccb92-146f-11eb-3a25-d714369df5ca
# ╠═bfd4f3ae-146f-11eb-36cb-9d8e97cab2ba
