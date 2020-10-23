### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ 88dcaae6-0d3c-11eb-2ffc-9d5335de20d2
using DataFrames, CSV, Dates, Distributions

# ╔═╡ 0c36a7ce-155b-11eb-2271-2d9133a99e8e
md"""
# Weather data

This notebook fits a distribution for temperatures.
"""

# ╔═╡ ca5034fc-1464-11eb-32f0-4f4d4ad10ea2
md"""
We import the data on weather in New York.
"""

# ╔═╡ 472a916c-0d3c-11eb-0a2b-230360f03207
weather_file = "./data/nyc.csv"

# ╔═╡ 8af16164-0d3c-11eb-3fdf-53d1f42a2e6f
weather_data = CSV.read(weather_file, DataFrame)

# ╔═╡ e0e3fb84-1464-11eb-234a-d9d01ded6183
md"""
Because the experiment stated that it was spring, we take the subset of data from March to June.
"""

# ╔═╡ cf6e414a-0d3c-11eb-18de-295b3dc92586
spring_data = let
	spring(date) = Dates.month(date) >= 3 && Dates.month(date) <= 6
	weather_data[spring.(weather_data.Date),:]
end

# ╔═╡ f95b9758-1464-11eb-0ad2-719d7df1a927
md"""
For my own convenience, I will convert all values to Celcius.
"""

# ╔═╡ 24f6c7f4-1463-11eb-3088-91b82422d915
function celcius(t)
	(t - 32) * 5/9
end

# ╔═╡ 0d0f1a18-1465-11eb-0866-cfdb293c1fb5
md"""
We assume that people's estimation of the temperature on a given day corresponds to the maximum temperature. So the prior distribution of temperature will be based on the maximum temperatures in spring.
"""

# ╔═╡ f4c8ccf4-0d40-11eb-1a83-8d92313bf533
max_temperatures = celcius.(spring_data[!, "Max.TemperatureF"])

# ╔═╡ 35313774-1465-11eb-0b5f-5528039464c1
md"""
This is fitted to a normal distribution.
"""

# ╔═╡ cfbff25c-0d40-11eb-1df1-b7634be673fb
prior_temp = fit(Normal, max_temperatures)

# ╔═╡ 498edc6c-1465-11eb-229c-bb6f702e8cf6
md"""
For convenience, we define two shorthand functions to get the prior probability of a temperature, or an interval of temperatures.
"""

# ╔═╡ b5a5b8f4-1464-11eb-1752-9fda6cdad83d
prior(degree) = pdf(prior_temp, degree)

# ╔═╡ bf5f8f32-1464-11eb-204c-53a61437ddd0
prior_range(lower, upper) = cdf(prior_temp, upper + 1) - cdf(prior_temp, lower)

# ╔═╡ Cell order:
# ╟─0c36a7ce-155b-11eb-2271-2d9133a99e8e
# ╠═88dcaae6-0d3c-11eb-2ffc-9d5335de20d2
# ╟─ca5034fc-1464-11eb-32f0-4f4d4ad10ea2
# ╠═472a916c-0d3c-11eb-0a2b-230360f03207
# ╠═8af16164-0d3c-11eb-3fdf-53d1f42a2e6f
# ╟─e0e3fb84-1464-11eb-234a-d9d01ded6183
# ╠═cf6e414a-0d3c-11eb-18de-295b3dc92586
# ╟─f95b9758-1464-11eb-0ad2-719d7df1a927
# ╠═24f6c7f4-1463-11eb-3088-91b82422d915
# ╟─0d0f1a18-1465-11eb-0866-cfdb293c1fb5
# ╠═f4c8ccf4-0d40-11eb-1a83-8d92313bf533
# ╟─35313774-1465-11eb-0b5f-5528039464c1
# ╠═cfbff25c-0d40-11eb-1df1-b7634be673fb
# ╟─498edc6c-1465-11eb-229c-bb6f702e8cf6
# ╠═b5a5b8f4-1464-11eb-1752-9fda6cdad83d
# ╠═bf5f8f32-1464-11eb-204c-53a61437ddd0
