using PyPlot
if isinstalled("seaborn")
    import Seaborn
end

function get_indiv(model::Model, paramset::Int)::Vector{Float64}
    best_generation::Int64 = readdlm(
        joinpath(
            model.path,
            "fitparam",
            "$paramset",
            "generation.dat"
        )
    )[1,1]
    best_indiv::Vector{Float64} = readdlm(
        joinpath(
            model.path,
            "fitparam",
            "$paramset",
            "fit_param$best_generation.dat"
        ),
    )[:,1]
    return best_indiv
end


function load_param(
        model::Model,
        paramset::Int)::Tuple{Array{Float64,1},Array{Float64,1}}
    best_indiv::Vector{Float64} = get_indiv(model, paramset)
    (p, u0) = model.update_param(best_indiv)
    return p, u0
end


function get_executable(model::Model)::Vector{Int}
    n_file::Vector{Int} = []
    fitparam_files::Vector{String} = readdir(
        joinpath(
            model.path,
            "fitparam"
        )
    )
    for file in fitparam_files
        if occursin(r"\d", file)
            push!(n_file, parse(Int64, file))
        end
    end
    empty_folder::Vector{Int} = []
    for (i, nth_param_set) in enumerate(n_file)
        if !isfile(
            joinpath(
                model.path,
                "fitparam",
                "$nth_param_set",
                "generation.dat"
            )
        )
            push!(empty_folder, i)
        end
    end
    for i in sort(empty_folder, rev=true)
        deleteat!(n_file, i)
    end
    return n_file
end


function validate!(model::Model, nth_param_set::Int64)
    (p, u0) = load_param(model, nth_param_set)
    if model.sim.simulate!(p, u0) isa Nothing
        return model, true
    else
        print("Simulation failed. #$nth_param_set\n")
        return model, false
    end
    return model
end


function get_norm_max(
        i::Int, j::Int, obs_name::String, simulations_all::Array{Float64,4})::Float64
    if length(model.sim.normalization) > 0
        norm_max::Float64 = (
            model.sim.normalization[obs_name]["timepoint"] !== nothing ? maximum(
                simulations_all[
                    i,
                    j,
                    model.sim.normalization[obs_name]["timepoint"],
                    [model.cond2idx(c) for c in model.sim.normalization[obs_name]["condition"]]
                ]
            ) : maximum(
                simulations_all[
                    i,
                    j,
                    :,
                    [model.cond2idx(c) for c in model.sim.normalization[obs_name]["condition"]]
                ]
            )
        )
        return norm_max
    else
        return 0.0
    end
end


function plot_timecourse(
        model::Model,
        n_file::Vector{Int},
        viz_type::String,
        show_all::Bool,
        stdev::Bool,
        simulations_all::Array{Float64,4},
        save_format::String)
    if !isdir(
        joinpath(
            model.path,
            "figure",
            "simulation",
            "$viz_type"
        )
    )
        mkpath(
            joinpath(
            model.path,
            "figure",
            "simulation",
            "$viz_type"
        )
        )
    end
    
    cmap = [
        "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
        "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf"
    ]
    shape = [
        "o", "v", "^", "<", ">", "8", "s", "p", "*", "h", "H", "D", "d", "P", "X"
    ]

    # rcParams
    rc("figure", figsize=(4, 3))
    rc("font", size=18)
    rc("axes", linewidth=1.5)
    rc("xtick.major", width=1.5)
    rc("ytick.major", width=1.5)
    rc("lines", linewidth=1.8)
    rc("lines", markersize=12)

    for (i, obs_name) in enumerate(model.observables)
        gca().spines["right"].set_visible(false)
        gca().spines["top"].set_visible(false)
        gca().yaxis.set_ticks_position("left")
        gca().xaxis.set_ticks_position("bottom")

        if viz_type != "experiment"
            if show_all
                for j in eachindex(n_file)
                    if length(model.sim.normalization) > 0
                        norm_max = get_norm_max(i, j, obs_name, simulations_all)
                    end
                    for (l, condition) in enumerate(model.sim.conditions)
                        plot(
                            model.sim.t,
                            simulations_all[i,j,:,l] ./ ifelse(
                                length(model.sim.normalization) == 0 || maximum(simulations_all[i,j,:,l]) == 0.0,
                                1.0,
                                norm_max
                            ),
                            color=cmap[l],
                            lw=0.5,alpha=0.35
                        )
                    end
                end
            end
            if viz_type == "average"
                normalized = Array{Float64,4}(
                    undef,
                    length(model.observables),length(n_file),length(model.sim.t),length(model.sim.conditions)
                )
                @inbounds for j in eachindex(n_file)
                    if length(model.sim.normalization) > 0
                        norm_max = get_norm_max(i, j, obs_name, simulations_all)
                    end
                    @simd for l in eachindex(model.sim.conditions)
                        normalized[i,j,:,l] = (
                            simulations_all[i,j,:,l] ./ ifelse(
                                length(model.sim.normalization) == 0 || maximum(simulations_all[i,j,:,l]) == 0.0,
                                1.0,
                                norm_max
                            )
                        )
                    end
                end
                if length(model.sim.normalization) > 0 && model.sim.normalization[obs_name]["timepoint"] === nothing
                    mean_norm_max::Float64 = maximum(
                        vcat(
                            [
                                [
                                    mean(
                                        filter(
                                            !isnan,normalized[i,:,k,l]
                                        )
                                    ) for k in eachindex(model.sim.t)
                                ] for l in eachindex(model.sim.normalization[obs_name]["condition"])
                            ]...
                        )
                    )
                    for j in eachindex(n_file)
                        for k in eachindex(model.sim.t)
                            for l in eachindex(model.sim.conditions)
                                if !isnan(mean_norm_max) && mean_norm_max != 0.0
                                    @inbounds normalized[i,j,k,l] /= mean_norm_max
                                end
                            end
                        end
                    end
                end
                for (l, condition) in enumerate(model.sim.conditions)
                    plot(
                        model.sim.t,[
                            mean(
                                filter(
                                    !isnan,normalized[i,:,k,l]
                                )
                            ) for k in eachindex(model.sim.t)
                        ],
                        color=cmap[l],
                        label=condition
                    )
                end
                if stdev
                    for (l, condition) in enumerate(model.sim.conditions)
                        y_mean = [
                            mean(
                                filter(
                                    !isnan,normalized[i,:,k,l]
                                )
                            ) for k in eachindex(model.sim.t)
                        ]
                        y_std = [
                            std(
                                filter(
                                    !isnan,normalized[i,:,k,l]
                                )
                            ) for k in eachindex(model.sim.t)
                        ]
                        fill_between(
                            model.sim.t,
                            y_mean - y_std, y_mean + y_std,
                            color=cmap[l],
                            lw=0,alpha=0.1
                        )
                    end
                end
            else
                norm_max = length(model.sim.normalization) > 0 ? (
                    model.sim.normalization[obs_name]["timepoint"] !== nothing ? maximum(
                        model.sim.simulations[
                            i,
                            model.sim.normalization[obs_name]["timepoint"],
                            [model.cond2idx(c) for c in model.sim.normalization[obs_name]["condition"]]
                        ]
                    ) : maximum(
                        model.sim.simulations[
                            i,
                            :,
                            [model.cond2idx(c) for c in model.sim.normalization[obs_name]["condition"]]
                        ]
                    )
                ) : 1.0
                for (l, condition) in enumerate(model.sim.conditions)
                    plot(
                        model.sim.t,
                        model.sim.simulations[i,:,l] ./ ifelse(
                            length(model.sim.normalization) == 0 || maximum(model.sim.simulations[i,:,l]) == 0.0,
                            1.0,
                            norm_max
                        ),
                        color=cmap[l],
                        label=condition
                    )
                end
            end
        end

        if isassigned(model.exp.experiments, i)
            exp_t = model.exp.get_timepoint(obs_name)
            if isassigned(model.exp.error_bars, i)
                for (l, condition) in enumerate(model.sim.conditions)
                    if condition in keys(model.exp.experiments[i])
                        exp_data = errorbar(
                            exp_t,
                            model.exp.experiments[i][condition],
                            yerr=model.exp.error_bars[i][condition],
                            lw=1,markerfacecolor="None",
                            color=cmap[l],
                            markeredgecolor=cmap[l],
                            ecolor=cmap[l],
                            fmt=shape[l],
                            capsize=8,
                            clip_on=false
                        )
                        for capline in exp_data[2]
                            capline.set_clip_on(false)
                        end
                        for barlinecol in exp_data[3]
                            barlinecol.set_clip_on(false)
                        end
                    end
                end
            else
                for (l, condition) in enumerate(model.sim.conditions)
                    if condition in keys(model.exp.experiments[i])
                        plot(
                            exp_t,
                            model.exp.experiments[i][condition],
                            shape[l],
                            color=cmap[l],
                            markerfacecolor="None",
                            markeredgecolor=cmap[l],
                            clip_on=false
                        )
                    end
                end
            end
        end
        xlabel("Time")
        ylabel(replace(obs_name, "_" => " "))
        savefig(
            joinpath(
                model.path,
                "figure",
                "simulation",
                "$viz_type",
                "$obs_name." * "$save_format"
            ),
            dpi=save_format == "pdf" ? nothing : 600,
            bbox_inches="tight"
        )
        close()
    end
end


function save_param_range(model::Model, n_file::Vector{Int}, save_format::String)
    search_idx::Tuple{Array{Int64,1},Array{Int64,1}} = model.search_idx()
    popt::Matrix{Float64} = zeros(length(n_file), length(search_idx[1]))
    @inbounds for (i, nth_param_set) in enumerate(n_file)
        best_indiv = get_indiv(model, nth_param_set)
        popt[i, :] = best_indiv[1:length(search_idx[1])]
    end

    # fig, ax = subplots(figsize=(4, length(search_idx[1]) / 5))
    # fig, ax = subplots(figsize=(8, 75))
    # rcParams
    rc("figure", figsize=(4, length(search_idx[1]) / 5))
    rc("font", size=6)

    # sns.despine()
    gca().spines["right"].set_visible(false)
    gca().spines["top"].set_visible(false)
    gca().yaxis.set_ticks_position("left")
    gca().xaxis.set_ticks_position("bottom")

    ax = Seaborn.boxplot(
        data=popt, orient="h", linewidth=0.5, fliersize=1, palette="Set2"
    )

    ax.set_xlabel("Parameter value")
    ax.set_ylabel("")
    ax.set_yticklabels([model.parameters.NAMES[i] for i in search_idx[1]])
    ax.set_xscale("log")

    savefig(
        joinpath(
            model.path,
            "figure",
            "param_range." * "$save_format"
        ),
        dpi=save_format == "pdf" ? nothing : 600,
        bbox_inches="tight"
    )
    close()
end


function run_simulation(
        model::Model;
        viz_type::String,
        show_all::Bool=false,
        stdev::Bool=false,
        save_format::String="pdf")
    if !isdir(
        joinpath(
            model.path,
            "figure"
        )
    )
        mkdir(
            joinpath(
                model.path,
                "figure"
            )
        )
    end

    if !(viz_type in ["best","average","original","experiment"])
        try
            parse(Int64, viz_type)
        catch
            error(
                "Avairable viz_type are: 'best','average','original','experiment','n(=1,2,...)'"
            )
        end
    end

    n_file::Vector{Int} = viz_type in ["original", "experiment"] ? [] : get_executable(model)

    simulaitons_all::Array{Float64,4} = fill(
        NaN,
        (
            length(model.observables),
            length(n_file),
            length(model.sim.t),
            length(model.sim.conditions)
        )
    )
    if viz_type != "experiment"
        if length(n_file) > 0
            if length(n_file) == 1 && viz_type == "average"
                error("viz_type should be best, not $viz_type")
            end
            for (i, nth_param_set) in enumerate(n_file)
                (model, is_successful) = validate!(model, nth_param_set)
                if is_successful
                    for j in eachindex(model.observables)
                        @inbounds simulaitons_all[j,i,:,:] = model.sim.simulations[j,:,:]
                    end
                end
            end
            best_fitness_all::Vector{Float64} = fill(Inf, length(n_file))
            for (i, nth_param_set) in enumerate(n_file)
                if isfile(
                    joinpath(
                        model.path,
                        "fitparam",
                        "$nth_param_set",
                        "best_fitness.dat"
                    )
                )
                    best_fitness_all[i] = readdlm(
                        joinpath(
                            model.path,
                            "fitparam",
                            "$nth_param_set",
                            "best_fitness.dat"
                        )
                    )[1,1]
                end
            end
            best_param_set::Int = n_file[argmin(best_fitness_all)]
            if viz_type == "best"
                model, _ = validate!(model, best_param_set)
            elseif viz_type != "average" && parse(Int64, viz_type) <= length(n_file)
                model, _ = validate!(model, parse(Int64, viz_type))
            elseif viz_type != "average" && parse(Int64, viz_type) > length(n_file)
                error(
                    @sprintf(
                        "n (%d) must be smaller than n_fitparam (%d)",
                        parse(Int64, viz_type), length(n_file)
                    )
                )
            end

            if isinstalled("seaborn") && length(n_file) > 1
                save_param_range(model, n_file, save_format)
            end

        else
            p::Vector{Float64} = param_values()
            u0::Vector{Float64} = initial_values()
            if model.sim.simulate!(p, u0) !== nothing
                error(
                    "Simulation failed."
                )
            end
        end
    end
    plot_timecourse(
        model,n_file,viz_type,show_all,stdev,simulaitons_all, save_format
    )
end