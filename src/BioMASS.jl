module BioMASS

using Printf
using LinearAlgebra
using StatsBase
using Statistics
using DelimitedFiles

export Model,
    optimize,
    optimize_continue,
    param2biomass,
    run_simulation,
    create_diffeq,
    new_curve!,
    get_bistable_regime


const requirements = [
    joinpath("name2idx", "parameters.jl"),
    joinpath("name2idx", "species.jl"),
    "set_model.jl",
    "observable.jl",
    "simulation.jl",
    "experimental_data.jl",
    "set_search_param.jl",
    "fitness.jl",
]

struct Model
    path::String
    parameters::Module
    species::Module
    observables::Vector{String}
    sim::Module
    exp::Module
    obj_func::Function
    cond2idx::Function
    search_idx::Function
    search_region::Function
    update_param::Function
    gene2val::Function
    val2gene::Function
    bestIndivVal2randGene::Function
end
function Model(model_path::String, show_info::Bool=false)
    for req in requirements
        include(joinpath(model_path, req))
    end
    if show_info
        print(
            "Model information\n"
            * "-----------------\n"
            * @sprintf(
                "%d species\n%d parameters, of which %d to be estimated",
                length(V.NAMES), length(C.NAMES), length(get_search_index()[1])
            )
        )
    end
    Model(
        model_path,
        C,
        V,
        observables,
        Sim,
        Exp,
        objective,
        conditions_index,
        get_search_index,
        get_search_region,
        update_param,
        decode_gene2val,
        encode_val2gene,
        encode_bestIndivVal2randGene,
    )
end


function isinstalled(pymodule::String)::Bool
    try
        pyimport(pymodule)
        return true
    catch
        return false
    end
end

include("convert.jl")
include("optimize.jl")
include("estimation/initial_population.jl")
include("estimation/converging.jl")
include("estimation/local_search.jl")
include("estimation/ga.jl")
if isinstalled("matplotlib")
    include("visualize.jl")
else
    function visualize(model::Model; kwargs...)
        error(
            "The Python package matplotlib could not be imported by pyimport.\n"
            * "Usually this means that you did not install matplotlib in the "
            * "Python version being used by PyCall."
        )
    end
end
include("continuation.jl")
end # module
