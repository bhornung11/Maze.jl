"""
Rectangle grid maze drawing preparation functions.
"""


export convert_links_to_points_rectangle


"""
    convert_links_to_points_rectangle(
        links::Array{Int, 2},
        n_row::Int,
        n_col::Int
    )

Takes a set of rectangular grid links and returns the grid coordinates
of the rectangles that represent the paths (i.e. "white squares").

# Arguments
- `links`::Array{Int, 2}: index pairs of the grid points that are linked
- `n_row::Int`: number of rows : number of grid rows
- `n_col::Int`: number of columns; number grid columns

# Returns
- `x::Array{Int, 1}`: abscissae of the link rectangles
- `y::Array{Int, 1}`: ordinates of the link rectangles
"""
function convert_links_to_points_rectangle(
        links::Array{Int, 2},
        n_row::Int,
        n_col::Int
    )

    n_in = div(length(links), 2)
    n_out = n_row * n_col + n_in

    x = zeros(Int, n_out)
    y = zeros(Int, n_out)

    # fill with the coordinates of the vertices
    k = 1
    for i in 1:n_col
        for j in 1:n_row
            x[k] = i * 2 - 1
            y[k] = j * 2 - 1
            k += 1
        end
    end

    for i in 1:n_in

        # get linked vertices
        source, target = links[1:2, i]
        i_source, j_source = index_1d_to_2d_grid(source, n_row)

        i_target, j_target = index_1d_to_2d_grid(target, n_row)

        # make space for the walls squares
        i_source = 2 * i_source - 1
        j_source = 2 * j_source - 1
        i_target = 2 * i_target - 1
        j_target = 2 * j_target - 1

        # calculate the indices of the links
        i_edge = div((i_source + i_target), 2)
        j_edge = div((j_source + j_target), 2)

        # append them to the coordinate array
        x[k] = i_edge
        y[k] = j_edge
        k += 1
    end

    return x, y
end


"""
convert_links_to_points_rectangle(
        edges::Array{Int, 2},
        n_row::Int
    )

Creates a line that connects the linked grid points.

# Arguments
- `links`::Array{Int, 2}: index pairs of the grid points that are linked
- `n_row::Int`: number of rows 

# Returns
- `x::Array{Int, 1}`: abscissae of lines connecting linked grid points
- `y::Array{Int, 1}`: ordinates of lines connecting linked grid points
"""
function convert_links_to_points_rectangle(
        links::Array{Int, 2},
        n_row::Int
    )

    n_in = div(length(links), 2)
    n_out = 3 * n_in

    x = ones(Float64, n_out) * NaN
    y = ones(Float64, n_out) * NaN

    for i in 1:n_in
        source, target = links[1:2, i]
        x_, y_ = index_1d_to_2d_grid(source, n_row)
        j = i * 3 - 2
        x[j] = x_
        y[j] = y_
        x_, y_ = index_1d_to_2d_grid(target, n_row)
        x[j + 1] = x_
        y[j + 1] = y_
    end

    return x, y
end
