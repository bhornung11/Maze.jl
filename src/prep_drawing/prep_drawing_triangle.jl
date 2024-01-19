"""
Triangle graph drawing prepartion utilities.
"""


include("../graphs/graph_tri.jl")


export select_sides_to_draw_tri

"""
select_sides_to_draw_tri(
    tri_graph::TriGraph, links::Array{Int, 2}
)Array{Array{Int, 1}, 1}

Selects the lines of a Deluanay maze which are to be drawn.

# Arguments
- tri_graph::TriGraph : triangulation graph
- links::Array{Int, 2} : triangle pairs which constitute the path

# Returns
- lines::Array{Int, 2}: lines to draw
    - x start, y start, x end, y end
"""
function select_sides_to_draw_tri(
        tri_graph::TriGraph,
        links::Array{Int, 2}
    )::Array{Array{Int, 1}, 1}

    lines = Array{Array{Int, 1}, 1}()

    # get points of the sides which are removed to create the links
    sides_excluded = Set(
        tri_graph.mapping[(i1, i2)] for  (i1, i2) in eachcol(links)
    )

    # map edges to sides
    for (s, t) in get_edges(tri_graph.tri)
        # ghost triangles
        if s < 1 || t < 1
            continue
        end

        # do not collect sides which are intersected by edges
        if (s, t) in sides_excluded
            continue
        end
        x1, y1 = tri_graph.tri.points[:, s]
        x2, y2 = tri_graph.tri.points[:, t]

        push!(lines, [Int(x1), Int(y1), Int(x2), Int(y2)])

    end 
    return lines
end
