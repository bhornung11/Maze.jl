"""
k-means++ algoritm components.
"""

using StatsBase


function init_seeds(xy::Array{T, 2}, n_seed::Int) where T

    n_point = size(xy)[2]

    if n_seed > n_point
        throw(
            ArgumentError(
                "Number of seeds $(n_seed) is greater than number of points $(n_point)."
            )
        )
    end

    if n_seed == n_point
        return xy
    end

    # 1st seed
    idcs = zeros(Int, n_seed)
    idcs[1] = sample(1:n_point)

    dists = fill(Inf64, n_point)
    
    # until all the seeds are chosen
    for i_seed in 2:n_seed

        # most recent seed
        seed_prev = xy[:, idcs[i_seed - 1]]
        
        # for all points
        for i_point in 1:n_point
            
            xy_ = xy[:, i_point]
            dist = calc_l2(seed_prev, xy_)
            
            if dist < dists[i_point]
                dists[i_point] = dist
            end

        end
        
        idcs[i_seed] = sample(1:n_point, Weights(dists))
        
    end

    return idcs

end


function calc_l2(p1::Array{T, 1}, p2::Array{T, 1}) where T
   
    dist = 0.0
    for (val1, val2) in zip(p1, p2)
        diff = val1 - val2
        dist += diff * diff
    end

    return dist

end
