"""
Border graph drawing hepers.
"""


"""
function extract_border_segments(graph::TriGraph, labels::Dict{Int, Int})

Extracts all border segments of a graph decomposition.

# Arguments
- graph::TriGraph : Delaunay graph
- labels::Dict{Int, Int} : vertex labels

# Returns
- borders::Dict{Int, Array{Array{Int, 1}, 1}} border segments by colour
"""
function extract_border_segments(
        graph::TriGraph,
        labels::Dict{Int, Int}
    )

 
    border_segments_external = extract_border_segments_external(graph, labels)
    border_segments = extract_border_segments_internal(graph, labels)

    for (label, segments) in border_segments_external
        append!(border_segments[label], segments)
    end

    return border_segments

end

"""
function extract_borders_segments_internal(graph::TriGraph, labels::Dict{Int, Int})

Extracts border segments between labeled regions.

# Arguments
- graph::TriGraph : Delaunay graph
- labels::Dict{Int, Int} : vertex labels

# Returns
- border_segments::Dict{Int, Array{Array{Int, 1}, 1}} border segments by colour
"""
function extract_border_segments_external(
        graph::TriGraph,
        labels::Dict{Int, Int}
    )

    border_segments = Dict(
        label => Array{Array{Int,1},1 }() for label in unique(values(labels))
    )
    mapping_side_edge = Dict(
        value => key for (key, value) in graph.mapping
    )

    for s in get_vertices(graph)
        label = labels[s]
        neighbours = get_neighbours(graph, s)

        # on the convex hull
        if length(neighbours) != 3
            p1, p2, p3 = graph.triangles[:, s]

            if !haskey(mapping_side_edge, order_two(p1, p2))
                push!(border_segments[label], [p1, p2])
            end
 
            if !haskey(mapping_side_edge, order_two(p2, p3))
                push!(border_segments[label], [p2, p3])
            end

            if !haskey(mapping_side_edge, order_two(p1, p3))
                push!(border_segments[label], [p1, p3])
            end

        end
    end

    return border_segments
end


"""
function extract_border_segments_internal(graph, labels)

Extracts those border segments which face the area external boundary.

# Arguments
- graph::TriGraph : Delaunay graph
- labels::Dict{Int, Int} : vertex labels

# Returns
- border_segments::Dict{Int, Array{Array{Int, 1}, 1}} border segments by colour
"""
function extract_border_segments_internal(
        graph::TriGraph,
        labels::Dict{Int, Int}
    )

    border_segments = Dict(
        label => Array{Array{Int,1},1 }() for label in unique(values(labels))
    )

    for ((s, t), (p1, p2)) in graph.mapping

        label1 = labels[s]
        label2 = labels[t]

        if label1 != label2
            push!(border_segments[label1], [p1, p2])
            push!(border_segments[label2], [p1, p2])
        end
    end

    return border_segments
end


"""
function chain_border_segments(segments::Array{Array{T, 1}, 1}) where T

Creates and ordered open chain of segments. Two segments are connected
if they have a point in common.

# Arguments
- `segments::Array{Array{T, 1}, 1}` : segments

# Returns
- `border::Array{T, 1}` : chain of connected points.
"""
function chain_border_segments(segments::Array{Array{T, 1}, 1}) where T
   
    if length(segments) == 0
        return Array{Array{T, 1}, 1}()
    end

    graph = DictGraph{T}()

    for (p1, p2) in segments
        push!(graph, p1, p2)
        push!(graph, p2, p1)
    end

    border = dfs(graph, segments[1][1])

    return border

end
