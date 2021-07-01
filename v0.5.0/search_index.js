var documenterSearchIndex = {"docs":
[{"location":"references/","page":"References","title":"References","text":"Nakakuki, T. et al. Ligand-specific c-Fos expression emerges from the spatiotemporal control of ErbB network dynamics. Cell 141, 884–896 (2010). https://doi.org/10.1016/j.cell.2010.03.054\nYao, G., Lee, T. J., Mori, S., Nevins, J. R. & You, L. A bistable Rb-E2F switch underlies the restriction point. Nat. Cell Biol. 10, 476–482 (2008). https://doi.org/10.1038/ncb1711\nBarr, A. R., Heldt, F. S., Zhang, T., Bakal, C. & Novák, B. A Dynamical Framework for the All-or-None G1/S Transition. Cell Syst. 2, 27–37 (2016). https://doi.org/10.1016/j.cels.2016.01.001\nRata, S. et al. Two Interlinked Bistable Switches Govern Mitotic Control in Mammalian Cells. Curr. Biol. 28, 3824-3832.e6 (2018). https://doi.org/10.1016/j.cub.2018.09.059","category":"page"},{"location":"usage/bifurcation_analysis/#Bifurcation-Analysis","page":"Bifurcation Analysis","title":"Bifurcation Analysis","text":"","category":"section"},{"location":"usage/bifurcation_analysis/","page":"Bifurcation Analysis","title":"Bifurcation Analysis","text":"A numerical study of the changes in the dynamics and stability of a system upon variations in its parameters.","category":"page"},{"location":"usage/bifurcation_analysis/","page":"Bifurcation Analysis","title":"Bifurcation Analysis","text":"(Image: )","category":"page"},{"location":"usage/bifurcation_analysis/#Procedure-for-stability-analysis-at-fixed-points","page":"Bifurcation Analysis","title":"Procedure for stability analysis at fixed points","text":"","category":"section"},{"location":"usage/bifurcation_analysis/","page":"Bifurcation Analysis","title":"Bifurcation Analysis","text":"Consider the following system of ordinary differential equations:","category":"page"},{"location":"usage/bifurcation_analysis/","page":"Bifurcation Analysis","title":"Bifurcation Analysis","text":"dfracdxdt = F(x)","category":"page"},{"location":"usage/bifurcation_analysis/","page":"Bifurcation Analysis","title":"Bifurcation Analysis","text":"Determine the fixed point vector, x^*, solving F(x^*) = 0\nConstruct the Jacobian matrix, J(x) = dfracpartial F(x)partial x\nCompute eigenvalues of J(x^*): J(x^*)  λE = 0\nConclude on stability or instability of x^* based on the real parts of eigenvalues\nAll eigenvalues have real parts less than zero → x^* is stable\nAt least one of the eigenvalues has a real part greater than zero → x^* is unstable","category":"page"},{"location":"usage/bifurcation_analysis/#Usage","page":"Bifurcation Analysis","title":"Usage","text":"","category":"section"},{"location":"usage/bifurcation_analysis/","page":"Bifurcation Analysis","title":"Bifurcation Analysis","text":"See examples/bifurcation.","category":"page"},{"location":"usage/parameter_estimation/#Parameter-Estimation","page":"Parameter Estimation","title":"Parameter Estimation","text":"","category":"section"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"(Image: )","category":"page"},{"location":"usage/parameter_estimation/#Core-functions","page":"Parameter Estimation","title":"Core functions","text":"","category":"section"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"Model(path_to_model::String)","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"Load a BioMASS model. The model must include the following files:","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"Name Content\nname2idx/ Names of model parameters and species\nset_model.jl Differential equation, parameters and initial condition\nobservalbe.jl Model observables for correlating simulation results with experimental observations\nsimulation.jl Simulation condition\nexperimental_data.jl Experimental measurements for determining parameters\nset_search_param.jl Model parameters to optimize and search region\nfitness.jl An objective function to be minimized, i.e., the distance between model simulation and experimental data","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"Parameters\npath_to_model::String\nThe model folder to read.\nReturns\nmodel::Model\nThe executable model in BioMASS.","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"optimize(model::Model, index_of_parameter_set::Int; popsize::Int=5, max_generation::Int=10000, allowable_error::Float64=0.0, n_children::Int=50, local_search_method::String=\"mutation\")","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"Find a parameter set that reproduces experimental observations.","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"Parameters\nmodel::Model\nThe BioMASS model object.\nindex_of_parameter_set::Int\nIndex of parameter sets.\npopsize::Int (default: 5)\nA multiplier for setting the total population size. The population has popsize * len(search_param) individuals.\nmax_generation::Int (default: 10000)\nThe maximum number of generations over which the entire population is evolved.\ninitial_threshold::Float64 (default: 1e12)\nAllowable error used to generate initial population. Default value is 1e12 (numerically solvable).\nallowable_error::Float64 (default: 0.0)\nOptimization stops when Best Fitness <= allowable_error.\nn_children::Int (default: 50)\nThe number of children used for local search NDM/MGG (\"mutation\").\nmaxiter::Int (default: 100)\nThe maximum number of iterations over which the entire population is evolved. This is used for the local search methods: \"Powell\", \"DE\" or \"CMAES\".\nlocal_search_method::String (default: \"mutation\")\nLocal search method used in GA. Should be one of\n\"mutation\" : NDM/MGG\n\"Powell\" : Modified Powell method\n\"DE\" : Differential Evolution (strategy: best2bin)\n\"CMAES\" : The CMA Evolution Strategy","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"run_simulation(model::Model, viz_type::String, show_all::Bool=false, stdev::Bool=false)","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"Save simulation results with optimized parameter values.","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"Parameters\nviz_type::String\n\"average\"\n\"best\"\n\"original\"\n\"experiment\"\nshow_all::Bool (default: false)\nWhether to show all simulation results.\nstdev::Bool (default: false)\nIf True, the standard deviation of simulated values will be shown (only available for \"average\" visualization type).\nsave_format::String (default: \"pdf\")\nEither \"png\" or \"pdf\", indicating whether to save figures as png or pdf format.","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"param2biomass(path_to_model::String)","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"Convert optimized parameters (fitparam/) and optimization process (logs/) into BioMASS format (out/).","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"Parameters\npath_to_model::String\nThe model folder including optimization results.","category":"page"},{"location":"usage/parameter_estimation/#Estimate-unknown-model-parameters","page":"Parameter Estimation","title":"Estimate unknown model parameters","text":"","category":"section"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"using BioMASS\n\nmodel = Model(\"./examples/fos_model\")\n\noptimize(model, 1, popsize=3, allowable_error=0.35, local_search_method=\"DE\")","category":"page"},{"location":"usage/parameter_estimation/#Simultaneous-parameter-optimization","page":"Parameter Estimation","title":"Simultaneous parameter optimization","text":"","category":"section"},{"location":"usage/parameter_estimation/#Using-module-Distributed","page":"Parameter Estimation","title":"Using module Distributed","text":"","category":"section"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"using Distributed\naddprocs(); # add worker processes\n@everywhere using BioMASS\n\n@everywhere begin\n    model = Model(\"./examples/fos_model\")\n    function optimize_parallel(i)\n        optimize(model, 1, popsize=3, allowable_error=0.35, local_search_method=\"DE\")\n    end\nend\n\npmap(optimize_parallel, 1:10)","category":"page"},{"location":"usage/parameter_estimation/#Calling-multiple-bash-scripts","page":"Parameter Estimation","title":"Calling multiple bash scripts","text":"","category":"section"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"main.jl","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"using BioMASS\n\nmodel = Model(\"./examples/fos_model\")\n\nif abspath(PROGRAM_FILE) == @__FILE__\n    optimize(\n        model,\n        parse(Int64, ARGS[1]),\n        max_generation=50,\n        allowable_error=0.35,\n        popsize=3,\n        local_search_method=\"CMAES\",\n        maxiter=1000,\n    )\nend","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"optimize_parallel.sh","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"#!/bin/sh\n\nfor i in $(seq 1 10); do\n    nohup julia -t 4 main.jl $i >> errout/$i.log  2>&1 &\ndone\n\n# The number of execution threads is controlled by using the -t command line argument (local_search_method == \"CMAES\").\n\n# To terminate the process,\n# $ pgrep -f main.jl | xargs kill -9","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"Run optimize_parallel.sh","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"$ mkdir errout\n$ sh optimize_parallel.sh","category":"page"},{"location":"usage/parameter_estimation/#How-to-track-optimization-process","page":"Parameter Estimation","title":"How to track optimization process","text":"","category":"section"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"The temporary result will be saved in path_to_model/logs/n.log after each iteration.","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"$ tail examples/fos_model/logs/1.log","category":"page"},{"location":"usage/parameter_estimation/#Visualization-of-simulation-results","page":"Parameter Estimation","title":"Visualization of simulation results","text":"","category":"section"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"The simulation results will be saved in figure/.","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"run_simulation(model, viz_type=\"best\", show_all=true)","category":"page"},{"location":"usage/parameter_estimation/#Conversion-of-optimized-parameters-into-BioMASS-format","page":"Parameter Estimation","title":"Conversion of optimized parameters into BioMASS format","text":"","category":"section"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"(Image: )","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"The converted items will be saved in path2model/dat2npy/out/.","category":"page"},{"location":"usage/parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"param2biomass(\"./examples/fos_model\")","category":"page"},{"location":"#BioMASS.jl","page":"Home","title":"BioMASS.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"(Image: License: MIT) (Image: Source) (Image: Actions Status)","category":"page"},{"location":"","page":"Home","title":"Home","text":"This module provides a Julia interface to the BioMASS parameter estimation.","category":"page"},{"location":"#Features","page":"Home","title":"Features","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Parameter estimation\nVisualization of simulation results\nBifurcation analysis","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"] add BioMASS","category":"page"},{"location":"","page":"Home","title":"Home","text":"    Pages = [\n        \"usage/parameter_estimation.md\",\n        \"usage/bifurcation_analysis.md\",\n    ]\n    Depth = 3","category":"page"}]
}
