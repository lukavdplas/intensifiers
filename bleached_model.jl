### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ 9618f500-1464-11eb-1392-71fd1a08f733
begin
	include("weather.jl")
	include("valence.jl")
end

# ╔═╡ 148427d6-155d-11eb-34c9-f74f68213b58
md"""
# Bleached model

The bleached model uses valence to predict the strength of an intensifier, but does not relate this to quality judgements about the weather.
"""

# ╔═╡ 791db33c-1464-11eb-132f-a1ae29ed628c
md"""
## Code import

We import code on the prior distribution of temperatures and the valence of messages.
"""

# ╔═╡ 1d6b6f7a-0d61-11eb-288b-911cc4f27369
md"""
## Possible worlds and messages

We start by defining the range of possible (classes of) worlds. These are degrees of temperatures, raning from -10 to 50 °C.
"""

# ╔═╡ 5d8e8c22-0d5c-11eb-1398-db1ee99ce9d1
temperatures = -10:50

# ╔═╡ 947deb66-155d-11eb-2d3d-7fdadcdcf0b8
md"""
The messages are not globally defined.

For a message like "fairly" (that is, the sentence _It is fairly warm today_), the model will assume that the speaker is essentially choosing between that message and saying nothing.

That is, the set of all possible messages will be `"fairly"` and nothing (`"null"`).
"""

# ╔═╡ 0a0ab47c-0d61-11eb-324b-c5b2c1e91d22
md"""
## Model definition

The model consists of a literal listener, a speaker and a pragmatic listener.

### Literal listener

The literal listener takes a temperature $t$, a message $m$ and a threshold $\theta$. The message is mostly included for consistency, but the listener does not actually use it.

They exclude the temperatures lower than the threshold, and weigh each remainig temperature by its prior probability.

$L_0(t \mid m, \theta) = \frac{(t \geq \theta) \cdot P(t) }{\sum_{t' \in T} (t' \geq \theta) \cdot P(t')}$

For the sake of efficiency, the function rewrites this as

$L_0(t \mid m, \theta) = \cases{
	0 & if t < θ \\ 
	\frac{P(t)}{P(T \geq \theta)} & otherwise}$


"""

# ╔═╡ d4a54716-0d5b-11eb-0a16-753470a2251a
function literal_listener(t::Int, message::String, θ::Int)
	if t < θ
		0.0
	else
		prior(t) / prior_range(θ, last(temperatures))
	end
end

# ╔═╡ 35b6004c-1467-11eb-3fad-19556d5cd64f
md"""
### Speaker

The speaker model gives the probability that a speaker will use message $m$. This is dependent on the temperature $t$, as well as several parameters:

*  The fuction $\Theta$, a set of ordered pairs $(m, \theta)$ where $m$ is a message and $\theta$ its threshold. The domain of $\Theta$ contains all the messages.
*  $\lambda$, which indicates how optimal the speaker behaves
*  $\gamma$, which is implemented in the cost

$S_1(m \mid t, \Theta, \lambda, \gamma) \sim \exp \big( \lambda \cdot U(t, m, \Theta(m), \gamma) \big)$

Or more precisely

$S_1(m \mid t, \Theta, \lambda, \gamma) = \frac{\exp \big( \lambda \cdot U(t, m, \Theta(m), \gamma) \big)}{\sum_{(m', \theta') \in \Theta} \exp \big( \lambda \cdot U(t, m', \theta', \gamma) \big)}$
"""

# ╔═╡ ceb05cd2-155e-11eb-27a1-89f28be152cb
md"""
The utility function:

$U(t, m, \theta, \gamma) = \ln L_0(t,m,\theta) - C(m, \gamma)$
"""

# ╔═╡ 65fc6748-155f-11eb-1516-7dce1207f2ca
md"""
The cost uses the valence of the message. In particular, we get:

$C(m, \gamma) = \cases{0 & if \textit{m} = nothing \\ \gamma \cdot (1 - V(m)) & otherwise }$
"""

# ╔═╡ d6582570-0d5d-11eb-28f0-ffb9703ffdc6
function cost(message, γ)
	if message != "null" 
		γ * (1 - valence(message))
	else
		0
	end
end

# ╔═╡ 83cde2ba-0d5d-11eb-3a96-957db0095676
function utility(degree, message, θ, γ)
	log(literal_listener(degree, message, θ)) - cost(message, γ)
end

# ╔═╡ 36206f76-0d5e-11eb-1a6f-a9df99c1a543
function speaker(t::Int, message::String, Θ::Dict, λ, γ)
	messages = keys(Θ)
	u(m) = exp(λ * utility(t, m, Θ[m], γ))
	
	u(message) / sum(u.(messages))
end

# ╔═╡ 3e4f5f1e-1467-11eb-2547-b15e947823e5
md"""
### Pragmatic listener

The pragmatic listener sums out over all values of possible thresholds.

For a given message $m$ and a threshold $\theta$, the pragmatic listener defines

$\Theta_{m,\theta} = \{(m, \theta), (\text{"null"}, \min(T)) \}$

So the threshold $\theta$ is used for the message $m$. We add the "null" message with the lowest possible threshold (so it's always true).

With this definition of $\Theta$, the listener can calculate the probability of a degree $t$ as

$P(t|m, \Theta, \lambda, \gamma) = S_1(m \mid t, \Theta, \lambda, \gamma) \cdot P(t)$

Summing out over all the thresholds, we get

$L_1(t|m, \lambda, \gamma) \sim \sum_{\theta \in T} S_1(m \mid t, \Theta_{m,\theta}, \lambda, \gamma) \cdot P(t)$

This value is normalised over all temperatures $t \in T$.
"""

# ╔═╡ 9273de26-0d5f-11eb-00ab-09d6d96b3142
function listener(t::Int, message::String, λ, γ)
	not_normalised(d) = let
		speaker_given_θ(θ) = let
			Θ = Dict("null" => first(temperatures), 
				message => θ)
			speaker(d, message, Θ, λ, γ)
		end
	
		prior(d) * sum(map(speaker_given_θ, temperatures))
	end
	
	not_normalised(t) / sum(not_normalised.(temperatures))
end

# ╔═╡ 4e68ab28-1564-11eb-2fcc-8924e0b96248
md"""
Lastle, we summarise the pragmatic listener by giving their expected temperature. This is the average of all temperatures weighted by their posterior probability.

$E(T|m, \lambda, \gamma) = \sum_{t \in T} t \cdot L_1(t|m, \lambda, \gamma)$
"""

# ╔═╡ 9f05e130-0d72-11eb-065f-0943c6ca045c
function listener_expectation(message, λ, γ)
	posteriors = map(t -> listener(t, message, λ, γ), temperatures)
	sum(temperatures .* posteriors) / sum(posteriors)
end

# ╔═╡ 4b6a77c4-1467-11eb-31fd-692d4b218d2c
md"""
### Full model

The full model definition takes the parameters $λ$ and $γ$ and returns the model as a function. This function takes a message and returns the expected temperature.
"""

# ╔═╡ 90930d48-1467-11eb-37ad-d71d5fe33c21
function model(λ, γ)
	message -> listener_expectation(message, λ, γ)
end

# ╔═╡ Cell order:
# ╟─148427d6-155d-11eb-34c9-f74f68213b58
# ╟─791db33c-1464-11eb-132f-a1ae29ed628c
# ╠═9618f500-1464-11eb-1392-71fd1a08f733
# ╟─1d6b6f7a-0d61-11eb-288b-911cc4f27369
# ╠═5d8e8c22-0d5c-11eb-1398-db1ee99ce9d1
# ╟─947deb66-155d-11eb-2d3d-7fdadcdcf0b8
# ╟─0a0ab47c-0d61-11eb-324b-c5b2c1e91d22
# ╠═d4a54716-0d5b-11eb-0a16-753470a2251a
# ╟─35b6004c-1467-11eb-3fad-19556d5cd64f
# ╠═36206f76-0d5e-11eb-1a6f-a9df99c1a543
# ╟─ceb05cd2-155e-11eb-27a1-89f28be152cb
# ╠═83cde2ba-0d5d-11eb-3a96-957db0095676
# ╟─65fc6748-155f-11eb-1516-7dce1207f2ca
# ╠═d6582570-0d5d-11eb-28f0-ffb9703ffdc6
# ╟─3e4f5f1e-1467-11eb-2547-b15e947823e5
# ╠═9273de26-0d5f-11eb-00ab-09d6d96b3142
# ╟─4e68ab28-1564-11eb-2fcc-8924e0b96248
# ╠═9f05e130-0d72-11eb-065f-0943c6ca045c
# ╟─4b6a77c4-1467-11eb-31fd-692d4b218d2c
# ╠═90930d48-1467-11eb-37ad-d71d5fe33c21
