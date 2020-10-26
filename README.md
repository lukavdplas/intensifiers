# intensifiers
Modelling the role of valence in intensifiers.

The model is implemented in Julia. I write all scripts as [Pluto](https://github.com/fonsp/Pluto.jl) notebooks.

If you don't have a Julia installation, I recommend looking at the `static` folder, which contains static HTML versions of each notebook. (I may convert these to PDF later.) These can be opened without a Julia installation and show my explanations for various functions.

If you want to interact with the code, I recommend opening it in Pluto, but they can be read or imported without a Pluto installation.

## Roadmap

* weather.jl - defines the prior probability distribution of temperatures
* quality.jl - defines a quality function on temperatures
* valence.jl - imports data on valence
* experimental_data.jl - import experimental results
* bleached_model.jl - definition of bleached model
* fitting.jl - parameter optimisation for the bleached model
* unbleached_model.jl - definition of the unbleached model
* plots.jl - various plots