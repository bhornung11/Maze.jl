"""
Graph cover algorithms.
"""

include("../utils/ordering.jl")
include("../graphs/graph.jl")

"""
function decompose_graph(graph::Graph{T}, seeds::Array{T, 1}) where T

Creates a vertex cover of a graph

# Arguments
- `graph::Graph{T}` : directed multigraph
- `seeds::Array{T, 1}` : starting vertices

# Returns
- `labels::Dict{T, Int}` vertex labels
"""
function decompose_graph(graph::Graph{T}, seeds::Array{T, 1}) where T

    # 0) setup
    graph_active = deepcopy(graph)

    set_active = Set{T}()

    labels = Dict(s => i for (i, s) in enumerate(seeds))

    # 1) seeds connectivity
    # do not consider seeds for labeling
    for s in seeds
        for t in get_neighbours(graph, s)
            remove_from_neighbours!(graph_active, t, s)
        end
    end

    for s in seeds
        # remove any seed that only has labeled neighbours
        if length(get_neighbours(graph_active, s)) == 0
            remove_from_graph!(graph_active, s)
        # oterwise mark as selectable
        else
            push!(set_active, s)
        end
    end

    # 2) grow connectivity
    while length(graph_active) != 0

        s = rand(set_active)
        t = rand(get_neighbours(graph_active, s))

        push!(labels, t => labels[s])

        for r in get_neighbours(graph, t)
            if r in graph_active
                n_neighbours = remove_from_neighbours!(graph_active, r, t)
                if n_neighbours == 0 &&  haskey(labels, r)
                    remove_from_graph!(graph_active, r)
                    if r in set_active
                        delete!(set_active, r)
                    end
                end
            end
        end

        if length(get_neighbours(graph_active, t)) == 0
            remove_from_graph!(graph_active, t)
            delete!(set_active, t)
        else
            push!(set_active, t)
        end

    end

    return labels

end
