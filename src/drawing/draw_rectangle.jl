"""
Rectangular grid drawing functions.
"""


export create_maze_bitmap_rectangle


"""
create_maze_bitmap_rectangle(
    x::Vector{Int},
    y::Vector{Int},
    n_row::Int,
    n_col::Int,
    width_square::Int,
    width_border::Int
)

Draws a grayscale bitmat of a rectangle maze.

# Arguments
- `x::Vector{Int}`: grid square centre abscissae
- `y::Vector{Int}`: grid square centre ordinates
- `n_row::Int`: number of grid rows
- `n_col::Int`: number of grid columns
- `width_square::Int`: width of s square
- `width_border::Int`: width of the grid square border

# Returns:
- `bitmap::Array{Float64, 2}`: bitmap to print
"""
function create_maze_bitmap_rectangle(
    x::Vector{Int},
    y::Vector{Int},
    n_row::Int,
    n_col::Int,
    width_square::Int,
    width_border::Int
)

    span_square = width_square - 1
    span_border = width_border - 1

    width = width_square + width_border

    # squares, borders around the squares
    # 2 * n - 1 squares
    n_pixel_row = (2 * n_row - 1) * width + width_border
    n_pixel_col = (2 * n_col - 1) * width + width_border

    # I saw a red door and I want to ...
    bitmap = zeros(Float64, (n_pixel_row, n_pixel_col))

    # draw border between squares
    for i in 0:n_row * 2 - 1
        i_top = i * width + 1
        bitmap[i_top:i_top + span_border, 1:n_pixel_col] .= 0.75
    end

    for i in 0:n_col * 2 - 1
        i_left = i * width + 1
        bitmap[1:n_pixel_row, i_left:i_left + span_border] .= 0.75
    end

    # fill all the vertices and edges in the draw area
    # @TODO order squares to optimise memory access
    for k in 1:length(x)
        i = x[k]
        j = y[k]
        # top left coordinates w/ border
        i_left = i * width - width_square + 1  
        i_top = j * width - width_square + 1
        bitmap[i_top:i_top + span_square, i_left:i_left + span_square] .= 1
    end

    return bitmap
end