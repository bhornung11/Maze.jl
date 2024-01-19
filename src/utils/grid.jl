
# we do not really need to export for these will be included
export index_1d_to_2d_grid
export index_2d_to_1d_grid


"""
index_1d_to_2d_grid(index::Int, n_row::Int)

Converts a rectangular grid index to a (column, row) index tuple (column major).
1 4 7 10
2 5 8 11
3 6 9 12
# Arguments
- `index::Int`: grid index
- `n_row:Int`: number of rows in the grid

# Returns
- `i::Int`: row index
- `j::Int`: column index
"""
function index_1d_to_2d_grid(index::Int, n_row::Int)

    i = (k = index % n_row) == 0 ? n_row : k
    j = k == 0 ? div(index, n_row) : div(index, n_row) + 1
    return j, i
end


"""
index_2d_to_1d_grid(index::Int, n_row::Int)

Converts a rectangular grid Cartesian index to a 1D index (column major).

# Arguments
- `index::Int`: grid index
- `n_row:Int`: number of rows in the grid

# Returns
- `index::Int`: row index
"""
function index_2d_to_1d_grid(i::Int, j::Int, n_row::Int)

    index = (j - 1) * n_row + i

    return index
end