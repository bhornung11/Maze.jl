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
    "`foreground::Int`: value to mark foreground pixels"
    foreground::Int
end


"""
ImageGridComponentGraph(x::Array{Int, 2}, foreground::Int)

# Arguments
- x::Array{Int, 2}: 2D array of labeled image components
- foreground::Int: value to mark foreground pixels

# Returns
- unnamed::ImageGridComponentGraph : graph representation of the image
    foreground and connected components
"""
function ImageGridComponentGraph(x::Array{Int, 2}, foreground::Int)

    n_row, n_col = size(x)
    
    # for lookup
    grid = RectangleGraph(n_row, n_col, n_row * n_col)

    connectivity = DictGraph{Int}()
    
    # examine each pixel
    for j in 1:n_col
        for i in 1:n_row
       
            label = x[i, j]
            # only investigate grid rectangles
            if label != foreground
                continue
            end

            # calculate 1D index
            source = index_2d_to_1d_grid(i, j, n_row)

            # get neighbours
            targets = get_neighbours(grid, source)

            # add to graph
            for target in targets
                # use grid index if the target is a rectangle
                # otherwise use component index
                target = (x[target] == foreground) ? target : x[target]
                push!(connectivity, source, target)
                push!(connectivity, target, source)
            end

        end
    end
    ImageGridComponentGraph(connectivity, x, foreground)

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