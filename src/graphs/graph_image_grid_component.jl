"""
2D image connected component graph.
"""


export ImageGridComponentGraph
export get_neighbours
export get_vertices


"""
struct ImageGridComponentGraph{Int} <: Graph{Int}

Graph representation of the image foreground and connected components
"""
struct ImageGridComponentGraph{Int} <: Graph{Int}
    "`connectivity::DictGraph{Int}`: component connectivity"
    connectivity::DictGraph{Int}
    "`image_components::Array{Int, 2}`: 2D array of labeled image components"
    image_components::Array{Int, 2}
end


"""
ImageGridComponentGraph(x::Array{Int, 2})

# Arguments
- x::Array{Int, 2}: 2D array of labeled image components

# Returns
- unnamed::ImageGridComponentGraph : graph representation of the image
    foreground and connected components

# Notes
The foreground is always zero. The connected components are labeled
with negative integers.
"""
function ImageGridComponentGraph(x::Array{Int, 2})

    n_row, n_col = size(x)
    
    # for lookup
    grid = RectangleGraph(n_row, n_col, n_row * n_col)

    connectivity = DictGraph{Int}()
    
    # examine each pixel
    for j in 1:n_col
        for i in 1:n_row
       
            # skip foreground (labeled components)
            if x[i, j] != 0
                continue
            end

            # calculate 1D index which will be the vertex
            source = index_2d_to_1d_grid(i, j, n_row)

            # get neighbours
            targets = get_neighbours(grid, source)

            # add to graph
            for target in targets
                # if the neighbour is a connected component use its label as the vertex
                # otherwise use the 1D grid index
                target = (x[target] == 0) ? target : x[target]
                push!(connectivity, source, target)
                push!(connectivity, target, source)
            end

        end
    end
    ImageGridComponentGraph(connectivity, x)

end


"""

"""
function get_neighbours(graph::ImageGridComponentGraph, vertex::Int)
    get_neighbours(graph.connectivity, vertex)
end


"""

"""
function get_vertices(graph::ImageGridComponentGraph)
    get_vertices(graph.connectivity)
end