"""
Base graph structure and algorithms.
"""

export Graph
export get_connected_components
export dfs

abstract type Graph{T} end


"""
function get_connected_components(graph::Graph{T}) where T

Returns the connected components as an array of arrays.

# Arguments
- `graph::Graph{T}`:graph

# Returns
- `components::Array{Array{T, 1}, 1}`: connected components
"""
function get_connected_components(graph::Graph{T}) where T

    vertices = Set(get_vertices(graph))

    components = Array{Array{T, 1}, 1}()
    while length(vertices) > 0

        component = Array{T, 1}()
        queue = [pop!(vertices)]

        while length(queue) > 0

            source = popfirst!(queue)
            push!(component, source)

            for target in get_neighbours(graph, source)

                if target in vertices
                    delete!(vertices, target)
                    push!(queue, target)
                end
            end
        end
        push!(components, component)
    end
    components
end


"""
function dfs(graph::Graph{T}, v::T) where T

Depth first search.

# Arguments
- graph::Graph{T} : graph
- v::T : vertex

# Returns
- visited::Array{T, 1} : vertices in depth first (pre)-order
"""
function dfs(graph::Graph{T}, v::T) where T
    
    i = 0
    visited = Dict{T, Int}()
    stack = [v]

    while length(stack) != 0
        v = popfirst!(stack)
        if !haskey(visited, v)
            i += 1
            push!(visited, v => i)
            for u in get_neighbours(graph, v)
                insert!(stack, 1, u)
            end
        end
    end

    # read out vertices in order
    visited = Dict(v => k for (k, v) in visited)
    visited = [visited[k] for k in 1:length(visited)]
    
    return visited

end
