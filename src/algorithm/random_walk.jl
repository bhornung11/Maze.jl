"""
Loop erased random walk
"""

include("../utils/ordering.jl")
include("../graphs/graph.jl")

export make_loop_erased_random_walk_maze_links

"""
make_loop_erased_random_walk_maze_links(graph::Graph{T}) where T

Creates a set of maze links by performing a loop erased random walk
on a connected graph.

# Arguments
- `graph::Graph{T}`: graph. The methods below must be implemented
    - `get_neighbours(graph::Graph{T}, vertex::T)::Array{T, 1}`
    - `get_vertices(graph::Graph{T})::Array{T, 1}`

# Returns
- links::Array{T, 2}: links. Each column is a link.
"""
function make_loop_erased_random_walk_maze_links(graph::Graph{T}) where T

    # bookkeeping
    statuses = Dict(vertex => 0 for vertex in get_vertices(graph))
    n = length(statuses)

    # storage for edges
    edges = zeros(T, (2, n - 1))
    i_edge = 0

    path = zeros(T, n)

    # initialise maze
    vertex, _ = pop!(statuses)
    
    # main traversing loop
    while length(statuses) != 0
        
        # get a vertex which is not in the maze
        vertex, _ = pop!(statuses)
        path[1] = vertex
        statuses[vertex] = -1
        n_in_path = 1

        # walk
        while true
            # select a neighbour
            neighbours = get_neighbours(graph, vertex)     
            vertex_next = rand(neighbours)
           
            # option i) loop detected
            if (i_loop_start = get(statuses, vertex_next, 0)) < 0

                # convert flag to index in the path
                i_loop_start = - i_loop_start

                # reset statuses from the 2nd element of the loop
                for i in i_loop_start + 1:n_in_path
                    statuses[path[i]] = 0
                    path[i] = 0
                end

                # truncate path until the 1st element of the loop
                n_in_path = i_loop_start

                # set 1st loop element as the current vertex and
                # continue the path from there
                vertex = path[n_in_path]
                continue
            end

            # option ii) neighbour is already in the maze -> add path to maze
            if get(statuses, vertex_next, 1) == 1
                for i in 1:n_in_path - 1

                    # add edges to the maze
                    source, target = path[i], path[i + 1]
                    edges[1, i_edge += 1] = source
                    edges[2, i_edge] = target

                    # bookkeeping
                    delete!(statuses, source)
                end
                # add last edge
                source = path[n_in_path]
                edges[1, i_edge += 1] = source
                edges[2, i_edge] = vertex_next

                # delete last vertex in path
                delete!(statuses, source)
                # finish path and go to get a new starting verex
                break
            end

            # option iii) vertex not in path or maze
            vertex = vertex_next
            path[n_in_path += 1] = vertex
            statuses[vertex] = - n_in_path

        end
    end
    # order the vertices of the links
    edges = sort!(edges, dims=1)

    return edges

end