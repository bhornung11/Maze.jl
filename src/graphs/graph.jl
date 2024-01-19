

export Graph
export get_connected_components

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
