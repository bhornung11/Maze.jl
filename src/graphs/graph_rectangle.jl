"""
Rectangular grid graph.
"""


export RectangleGraph
export get_neighbours
export get_vertices
export get_shared_sides_rectangle


"""
    RectangleGraph{Int} <:Graph{Int}

Structure to represent a rectangular grid graph.
"""
struct RectangleGraph{Int} <:Graph{Int}
    """`n_row::Int`: number of rows"""
    n_row::Int
    """`n_column::Int`: number of columns"""
    n_column::Int
    """`n_vertex::Int`: number of grid points"""
    n_vertex::Int
end


"""
    RectangleGraph(n_row::Int, n_column::Int)

Constructor of the `RectangleGraph` `struct`

# Arguments
- `n_row::Int`: number of rows
- `n_column::Int`: number of columns
"""
RectangleGraph(n_row::Int, n_column::Int) = RectangleGraph(n_row, n_column, n_row * n_column)


"""
    get_neighbours(graph::RectangleGraph, vertex::Int)

Retrieves the neighbours of a vertex in a rectangular grid graph.

# Arguments
- `graph::RectangleGraph`: rectangular graph
- `vertex::Int`: vertex index. The indices are in *column* major order.
"""
function get_neighbours(graph::RectangleGraph, vertex::Int)

    if vertex > graph.n_vertex || vertex < 1
        msg = "Vertex must be in [1, $(graph.n_vertex)]. Got: $(vertex)"
        throw(ArgumentError(msg))
    end

    i = 0
    neighbours = zeros(Int, 4)

    if vertex % graph.n_row != 1
        neighbours[i += 1] = vertex - 1
    end

    if vertex % graph.n_row != 0
        neighbours[i += 1] = vertex + 1
    end

    if (left = vertex - graph.n_row) > 0
        neighbours[i += 1] = left
    end

    if (right = vertex + graph.n_row) < graph.n_vertex
        neighbours[i += 1] = right
    end

    return neighbours[1:i]

end

"""
    get_vertices(graph::RectangleGraph)

Returns and array of the vertex indices of a rectangular grid graph.

# Arguments
- `graph::RectangleGraph`: graph
"""
function get_vertices(graph::RectangleGraph)
    return collect(1:graph.n_vertex)
end


"""
get_shared_sides_rectangle(source::Int, target::Int, n_row::Int)::Tuple{Int, int}

Determines at which sides two grid rectangles are connected. N: 1, E: 2, S: 3 W: 4.

# Arguments
- source::Int: 1D grid index
- target::Int: 1D grid index
- n_row::Int: number of rows

# Returns
- side_source::Int: side index
- side_target::Int: side index
"""
function get_shared_sides_rectangle(
        source::Int,
        target::Int,
        n_row::Int
    )::Tuple{Int, Int}

    diff_index = target - source

    if diff_index == 1
        side_source = 3
        side_target = 1
    elseif diff_index == -1
        side_source = 1
        side_target = 3
    elseif diff_index == n_row
        side_source = 2
        side_target = 4
    elseif diff_index == - n_row
        side_source = 4
        side_target = 2
    else
        throw(ArgumentError(
            "indices $(source) and $(target) are not consistent with the number of rows $(n_row)"
        ))
    end

    return side_source, side_target
end
