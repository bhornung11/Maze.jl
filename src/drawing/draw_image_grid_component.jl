"""
Connected component image graph drawing.
"""


export select_lines_to_draw_component


function select_lines_to_draw_component(
    graph::ImageGridComponentGraph,
    links::Array;
    width::Int=5
)

    n_row, _ = size(graph.image_components)

    lines = Array{Array{Int, 1}, 1}()

    # indices of sides which are not draw due to being intersected
    # by a path
    sides_to_omit = select_sides_to_omit_component(
        graph.image_components, links
    )

    empty_link = Array{Int}(undef, 1, 1)

    # loop over all vertices
    for vertex in get_vertices(graph)

        # but ignore components
        if vertex < 0
            continue
        end

        # get the side coordinates
        sides = get_rectangle_sides(vertex, n_row, width)

        # look up which sides not to render
        if length(links) == 0
            idcs = empty_link
       else
            idcs = sides_to_omit[vertex]
        end

        # select and append lines to draw
        append!(lines, sides[setdiff(1:end, idcs)])
    end

    lines

end


"""
get_rectangle_sides(index::Int, n_row::Int, factor::Int)::Array{Array{Int, 1}, 1}

# Arguments
- index::Int: 1D grid rectangle index
- n_row::Int: number of rows
- width::Int: rectangle (square) width

# Returns
- sides::Array{Array{Int, 1}, 1}: N/E/S/W side coordinates
- x1, y1, x2, y2
"""
function get_rectangle_sides(
    index::Int, 
    n_row::Int,
    width::Int
)::Array{Array{Int, 1}, 1}

    i, j = index_1d_to_2d_grid(index, n_row)

    i_canvas = (i - 1) * width + 1  
    j_canvas = (j - 1) * width + 1

    sides = Array{Array{Int, 1}, 1}()

    # north
    push!(sides, [i_canvas, j_canvas, i_canvas, j_canvas + width])

    # east
    push!(sides, [i_canvas, j_canvas + width, i_canvas + width, j_canvas + width])

    # south
    push!(sides, [i_canvas + width, j_canvas + width, i_canvas + width, j_canvas])

    # west
    push!(sides, [i_canvas + width, j_canvas, i_canvas, j_canvas])

    return sides

end
