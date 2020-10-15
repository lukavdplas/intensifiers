### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ 88dcaae6-0d3c-11eb-2ffc-9d5335de20d2
using CSV

# ╔═╡ 91983c04-0d3c-11eb-3329-23d2ccb973cc
using DataFrames

# ╔═╡ 073b591e-0d3d-11eb-3eb7-ff80c3c4309f
using Dates

# ╔═╡ 71bbd610-0d3d-11eb-13e8-cde4663c8962
using Plots

# ╔═╡ 0e6c7f66-0d41-11eb-1d3c-c7ff357e99f1
using Distributions

# ╔═╡ 32e4ff1c-0d3c-11eb-12da-b5eb888ce221
data_path = "./data/"

# ╔═╡ 472a916c-0d3c-11eb-0a2b-230360f03207
weather_file = data_path * "nyc.csv"

# ╔═╡ 8af16164-0d3c-11eb-3fdf-53d1f42a2e6f
weather_data = CSV.read(weather_file, DataFrame)

# ╔═╡ cf6e414a-0d3c-11eb-18de-295b3dc92586
spring_data = let
	spring(date) = Dates.month(date) >= 3 && Dates.month(date) <= 6
	weather_data[spring.(weather_data.Date),:]
end

# ╔═╡ c9d6e56e-0d3e-11eb-06af-1538ffdf2c24
function celcius(T)
	(T - 32) * 5/9
end

# ╔═╡ 271439c4-0d40-11eb-0a04-e319bdf313de
function convert(T_data)
	no_missing = filter(T -> typeof(T) != Missing, T_data)
	converted = celcius.(no_missing)
end

# ╔═╡ f4c8ccf4-0d40-11eb-1a83-8d92313bf533
max_temperatures = convert(spring_data[!, "Max.TemperatureF"])

# ╔═╡ 05198e34-0d3e-11eb-2631-3929e01112f8
histogram(max_temperatures, normalize=true,
	xlabel = "T", ylabel = "frequency", legend = nothing)

# ╔═╡ cfbff25c-0d40-11eb-1df1-b7634be673fb
temp_distribution = fit(Normal, max_temperatures)

# ╔═╡ 32781b9a-0d41-11eb-2b14-a14cffbab6c5
let
	temps = -10:45
	plot(temps, pdf.(temp_distribution, temps), 
		xlabel = "T", ylabel = "P", legend = nothing)
end

# ╔═╡ Cell order:
# ╠═88dcaae6-0d3c-11eb-2ffc-9d5335de20d2
# ╠═91983c04-0d3c-11eb-3329-23d2ccb973cc
# ╠═073b591e-0d3d-11eb-3eb7-ff80c3c4309f
# ╠═71bbd610-0d3d-11eb-13e8-cde4663c8962
# ╠═0e6c7f66-0d41-11eb-1d3c-c7ff357e99f1
# ╠═32e4ff1c-0d3c-11eb-12da-b5eb888ce221
# ╠═472a916c-0d3c-11eb-0a2b-230360f03207
# ╠═8af16164-0d3c-11eb-3fdf-53d1f42a2e6f
# ╠═cf6e414a-0d3c-11eb-18de-295b3dc92586
# ╠═c9d6e56e-0d3e-11eb-06af-1538ffdf2c24
# ╠═271439c4-0d40-11eb-0a04-e319bdf313de
# ╠═f4c8ccf4-0d40-11eb-1a83-8d92313bf533
# ╠═05198e34-0d3e-11eb-2631-3929e01112f8
# ╠═cfbff25c-0d40-11eb-1df1-b7634be673fb
# ╠═32781b9a-0d41-11eb-2b14-a14cffbab6c5
