### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ 5cff00b2-1472-11eb-2d21-cbd1d16ff562
using Statistics, Optim, Plots

# ╔═╡ 8629d0fe-1470-11eb-39db-153f110402c0
begin
	include("experimental_data.jl")
	include("bleached_model.jl")
end

# ╔═╡ 973c7f4c-152c-11eb-092d-73f17dfcca7f
md"""
# Fitting the bleached model

In in this notebook, we fit the bleached model to the experimental data.
"""

# ╔═╡ 7915cd84-1513-11eb-1dae-4317161e00e5
md"""
We import the experimental data and the bleached model.
"""

# ╔═╡ 85610040-1513-11eb-0d9e-1151ebdf8c8a
md"""
## Parameter optimisation

The model has two parameters, λ and γ. λ determines how optimal the speaker is, γ determines the weight of the valence of an intensifier. We want to find a configuration for λ and γ where the model best matches the experimental data.

For each intensifier, the target value is the mean response from all participants. This gives the expected temperature (in Celcius) given a statement _"It is [intensifier] warm today._
"""

# ╔═╡ b0fe8740-1471-11eb-1297-cbe14c2f7cb1
targets = mean_response.(intensifiers)

# ╔═╡ cf9b4512-1513-11eb-0acc-21075f99691d
md"""
Given the parameter settings, the model will make a prediction for each intensifier. The result is evaluated as the mean square error between the predictions and the target values.
"""

# ╔═╡ fa85d25e-1470-11eb-3969-a94f534bb6e3
function evaluate(predictions)
	squared_errors = map(zip(predictions, targets)) do (prediction, target)
		(prediction - target) ^ 2
	end
	
	mean(squared_errors)
end

# ╔═╡ 07020d88-1514-11eb-00ae-fdde336478bb
md"""
We define a function that gives the evaluation for a configuration of the parameters. It creates a model with the parameters, makes a prediction for each intensifiers, and returns the evaluation.
"""

# ╔═╡ 69c72356-1472-11eb-3dd1-91764ef58f5c
function model_evaluation(parameters)
	λ, γ = parameters
	predictor = model(λ, γ)
	predictions = predictor.(intensifiers)
	evaluate(predictions)
end

# ╔═╡ 4544173a-1514-11eb-3aba-79fbfce5e6f5
md"""
Now we use the `Optim` package to explore the parameter space. We provide initial values for λ and γ and let the optimiser find the values that minimise the error.

The initial values are based on some manual exploration of the results. These seem to be close to the optimal values, which will make optimisation easier.
"""

# ╔═╡ e992ff8a-1470-11eb-1897-8daae30b7f8e
initial_λ = 3.0

# ╔═╡ 9bc90c9a-1470-11eb-3ba2-2d792a0d3584
initial_γ = 0.5

# ╔═╡ 2f4b16ba-1512-11eb-1564-0340593d41d3
result = optimize(model_evaluation, [initial_λ, initial_γ], time_limit = 300)

# ╔═╡ 481e4268-1527-11eb-0994-fd9bb1adf893
md"""
This gives us our optimal values for λ and γ:
"""

# ╔═╡ b9550506-1523-11eb-0f62-49ff91aea837
optimal_λ, optimal_γ = Optim.minimizer(result)

# ╔═╡ 55bb7f4e-1529-11eb-02ed-912a30db7284
optimal_result = Optim.minimum(result)

# ╔═╡ 418cf752-1527-11eb-3c34-ad42909c027d
md"""
## Manual inspection

We used a time limit on the optimisation process for practical reasons. It received a "failure" status, meaning it ran out of time before finding an optimal configuration. That can simply mean that the achieved configuration is close to optimal, but could be finetuned more. That's an acceptable result for our purposes.

However, it is also possible that we're still quite far away from an optimal configuration. That would not be acceptable, and we would need to change our inital values to get a better result.

As a quick inspection of results, we plot the effect of changing λ and γ independently.

If `optimal_λ` and `optimal_γ` are (close to) optimal, the optimal value should be a global minimum in the plotted range. Note that the implication does not work the other way around: this is not proof that the configuration is optimal, but it is a minimum requirement.
"""

# ╔═╡ 78c2a8c0-1527-11eb-0213-397af5203505
λ_values = 1.0 : 5.0

# ╔═╡ 7ec91fc4-1527-11eb-2b8c-7517dc7b6532
λ_results = map(λ_values) do λ
	model_evaluation([λ, optimal_γ])
end

# ╔═╡ e2338fb4-1526-11eb-3ad4-5b702a514b7d
let
	plot(xlabel = "λ", ylabel = "MSE")
	plot!(λ_values, λ_results, label = "exploration")
	scatter!([optimal_λ], [optimal_result], label = "optimal_λ")
end

# ╔═╡ 9fa4b050-1527-11eb-041c-5d3e5d42d6f3
γ_values = 0.0 : 0.2 : 1.0

# ╔═╡ a4f9043e-1527-11eb-2de3-11c9622135a5
γ_results = map(γ_values) do γ
	model_evaluation([optimal_λ, γ])
end

# ╔═╡ 83850c5e-1526-11eb-2c4c-9502f129e9b1
let
	plot(xlabel = "γ", ylabel = "MSE")
	plot!(γ_values, γ_results, label = "exploration")
	scatter!([optimal_γ], [optimal_result], label = "optimal_γ")
end

# ╔═╡ Cell order:
# ╟─973c7f4c-152c-11eb-092d-73f17dfcca7f
# ╠═5cff00b2-1472-11eb-2d21-cbd1d16ff562
# ╟─7915cd84-1513-11eb-1dae-4317161e00e5
# ╠═8629d0fe-1470-11eb-39db-153f110402c0
# ╟─85610040-1513-11eb-0d9e-1151ebdf8c8a
# ╠═b0fe8740-1471-11eb-1297-cbe14c2f7cb1
# ╟─cf9b4512-1513-11eb-0acc-21075f99691d
# ╠═fa85d25e-1470-11eb-3969-a94f534bb6e3
# ╟─07020d88-1514-11eb-00ae-fdde336478bb
# ╠═69c72356-1472-11eb-3dd1-91764ef58f5c
# ╟─4544173a-1514-11eb-3aba-79fbfce5e6f5
# ╠═e992ff8a-1470-11eb-1897-8daae30b7f8e
# ╠═9bc90c9a-1470-11eb-3ba2-2d792a0d3584
# ╠═2f4b16ba-1512-11eb-1564-0340593d41d3
# ╟─481e4268-1527-11eb-0994-fd9bb1adf893
# ╠═b9550506-1523-11eb-0f62-49ff91aea837
# ╠═55bb7f4e-1529-11eb-02ed-912a30db7284
# ╟─418cf752-1527-11eb-3c34-ad42909c027d
# ╠═78c2a8c0-1527-11eb-0213-397af5203505
# ╠═7ec91fc4-1527-11eb-2b8c-7517dc7b6532
# ╠═e2338fb4-1526-11eb-3ad4-5b702a514b7d
# ╠═9fa4b050-1527-11eb-041c-5d3e5d42d6f3
# ╠═a4f9043e-1527-11eb-2de3-11c9622135a5
# ╠═83850c5e-1526-11eb-2c4c-9502f129e9b1
