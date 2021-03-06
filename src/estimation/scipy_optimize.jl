module SciPyOptimize

export fmin_powell, fmin_de

using PyCall

function __init__()
    py"""
    import warnings
    import numpy as np
    from scipy.optimize import minimize, differential_evolution
    from typing import Callable


    warnings.filterwarnings('ignore')
    
    def modified_powell(
            objective: Callable,
            n_gene: int,
            population: np.ndarray,
            ip: np.ndarray,
            maxiter: int,
    ) -> np.ndarray:
        lower = np.min(population[:, :n_gene], axis=0)
        upper = np.max(population[:, :n_gene], axis=0)
        direc = np.identity(n_gene) * 0.3 * (upper - lower)
        res = minimize(
            objective,
            population[ip[0], :n_gene],
            method='Powell',
            bounds=tuple(zip(lower, upper)),
            callback=lambda xk: True
            if objective(xk) < objective(population[ip[0], :n_gene])
            else False,
            options={
                #'disp': True,
                'xtol': 0.1,
                'ftol': 1.0,
                'maxiter': maxiter,
                'maxfev': 1000 * n_gene,
                'direc': direc,
            }
        )
        obj_val = objective(res.x)
        if obj_val < objective(population[ip[0], :n_gene]):
            population[ip[0], :n_gene] = res.x
            population[ip[0], -1] = obj_val
        return population
    

    def de_best2bin(
            objective: Callable,
            n_gene: int,
            population: np.ndarray,
            ip: np.ndarray,
            maxiter: int,
    ) -> np.ndarray:
        lower = np.min(population[:, :n_gene], axis=0)
        upper = np.max(population[:, :n_gene], axis=0)
        res = differential_evolution(
            objective,
            tuple(zip(lower, upper)),
            strategy='best2bin',
            mutation=(0.0, 0.3),
            recombination=0.9,
            maxiter=maxiter,
            popsize=1,
            polish=False,
            init=population[ip, :n_gene],
        )
        obj_val = objective(res.x)
        if obj_val < objective(population[ip[0], :n_gene]):
            population[ip[0], :n_gene] = res.x
            population[ip[0], -1] = obj_val
        return population
    """
end


function fmin_powell(
        objective::Function,
        n_gene::Int,
        population::Matrix{Float64},
        ip::Vector{Int},
        maxiter::Int
)::Matrix{Float64}
    return py"modified_powell"(objective, n_gene, population, ip .- 1, maxiter)
end


function fmin_de(
        objective::Function,
        n_gene::Int,
        population::Matrix{Float64},
        ip::Vector{Int},
        maxiter::Int
)::Matrix{Float64}
    return py"de_best2bin"(objective, n_gene, population, ip .- 1, maxiter)
end

end # module