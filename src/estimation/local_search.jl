using CMAEvolutionStrategy

if isinstalled("scipy.optimize")
    include("scipy_optimize.jl")
    using .SciPyOptimize
end

function local_search!(
        objective::Function,
        ip::Vector{Int64},
        population::Matrix{Float64},
        n_population::Int64,
        n_gene::Int64;
        method::String,
        n_children::Int64,
        maxiter::Int64)::Matrix{Float64}
    if method == "mutation"
        idx::BitArray{1} = trues(n_population)
        idx[ip[1]] = false

        children::Matrix{Float64} = zeros(n_children, n_gene + 1)

        for i in 1:n_children
            ip[2:end] = sample(
                collect(1:n_population)[idx], n_gene + 1, replace=false
            )
            children[i, :] = mutation(objective, population[ip, :], n_gene)
        end

        family::Matrix{Float64} = zeros(n_children + 1, n_gene + 1)
        @inbounds for i in 1:n_gene + 1
            @simd for j in 1:n_children
                family[j, i] = children[j, i]
            end
            family[n_children + 1, i] = population[ip[1], i]
        end

        family = sortslices(family, dims=1, by=x -> x[end])

        for i in 1:n_gene + 1
            @inbounds population[ip[1], i] = family[1, i]  # Best
        end
    elseif method == "powell"
        population = fmin_powell(objective, n_gene, population, ip, maxiter)
    elseif method == "de"
        population = fmin_de(objective, n_gene, population, ip, maxiter)
    elseif method == "cmaes"
        x0 = [population[ip[1], i] for i in 1:n_gene]
        lb = vec(minimum(population[:, 1:n_gene], dims=1))
        ub = vec(maximum(population[:, 1:n_gene], dims=1))
        s0 = 0.25 * median(ub - lb)
        result = CMAEvolutionStrategy.minimize(
            objective, x0, s0;
            lower=lb,
            upper=ub,
            verbosity=0,
            multi_threading=true,
            maxiter=maxiter,
            maxfevals=1000 * n_gene,
        )
        x_best_fit = xbest(result)
        obj_val = objective(x_best_fit)
        if obj_val < objective(x0)
            for i in 1:n_gene
                @inbounds population[ip[1], i] = x_best_fit[i]
            end
            population[ip[1], end] = obj_val
        end
    end
    population = sortslices(population, dims=1, by=x -> x[end])

    return population
end


function mutation(
        objective::Function, 
        parents::Matrix{Float64}, 
        n_gene::Int64)::Vector{Float64}
    # Normal Distribution Mutation
    child::Vector{Float64} = zeros(n_gene + 1)

    GAMMA::Float64 = 0.35 / sqrt(n_gene)

    t2::Vector{Float64} = zeros(n_gene)
    centroid::Vector{Float64} = reshape(
        mean(parents[2:end, 1:n_gene], dims=1), n_gene
    )

    for i in 1:n_gene + 1
        t2 += randn() * GAMMA * (parents[i + 1, 1:n_gene] - centroid)
    end

    @inbounds for i in 1:n_gene
        child[i] = clamp(parents[1, i] + t2[i], 0.0, 1.0)
    end

    child[end] = objective(child[1:n_gene])

    return child
end