"""
Delaunay triangulation graph and utilities.
"""


using DelaunayTriangulation


export TriGraph
export remove_from_graph!
export remove_from_neighbours!


"""
Triangular space partitioning graph
"""
struct TriGraph{T} <: Graph{T}
    "`graph::Dict{T, Array{T, 1}}` triangle connectivity"
    graph::Dict{T, Array{T, 1}}
    "`mapping::Dict{Tuple{Int, Int}, Tuple{T, T}}` triangle-pair--side mapping"
    mapping::Dict{Tuple{Int, Int}, Tuple{T, T}}
    "`tri::DelaunayTriangulation.Triangulation`: triangulation"
    tri::DelaunayTriangulation.Triangulation
    "triangles::Array{Int, 2}"
    triangles::Array{Int, 2}
end


"""
TriGraph{Int}(points::Array{Int, 2})

Constructs a triangulation graph from a set of points.

# Arguments
- points::Array{Int, 2}:points

# Returns
- unnamed::TriGraph{Int}: triangulation graph
"""
function TriGraph{Int}(points::Array{Int, 2})
    # the triangulation subroutine only accepts floats
    tri = triangulate(points * 1.0)
    TriGraph{Int}(tri)
    
end


"""
TriGraph{T}(tri::DelaunayTriangulation.Triangulation) where T

# Arguments
- `tri::DelaunayTriangulation.Triangulation`: triangulation

# Returns
- unnamed::TriGraph{T}: traingulation graph
"""
function TriGraph{T}(tri::DelaunayTriangulation.Triangulation) where T
    graph, mapping, triangles = create_triangle_graph(tri)
    TriGraph{T}(graph.graph, mapping, tri, triangles)
end


"""
get_vertices(graph::TriGraph{T})::Array{T, 1} where T

# Parameters
- `graph::TriGraph{T})`: triangulation graph

# Returns
- unnamed::Array{T, 1}:: all triangles
"""
function get_vertices(graph::TriGraph{T})::Array{T, 1} where T
    return collect(keys(graph.graph))
end


"""
get_neighbours(graph::TriGraph{T}, vertex::T)::Array{T, 1} where T

Retrieves the triangle adjacent to a query triangle.

# Arguments
- graph::TriGraph{T}: triangle connectivity graph
- vertex::T: query triangle

# Returns
- unnamed::Array{T, 1}: triangle adjacent to the query triangle
"""
function get_neighbours(graph::TriGraph{T}, vertex::T)::Array{T, 1} where T
    return graph.graph[vertex]
end


"""
function remove_from_neighbours!(graph::TriGraph{T}, source::T, target::T) where T

Removes a neighbour from the neighbours.

# Arguments
- graph::TriGraph{T}
- source::T : source
- target::T : target to remove

# Returns
- n_neighbour::Int : number of neighbours after deletion
"""
function remove_from_neighbours!(graph::TriGraph{T}, source::T, target::T) where T
    neighbours = graph.graph[source]
    deleteat!(neighbours, findall(x->x==target, neighbours))
    n_neighbour = length(neighbours)
    return n_neighbour
end


"""
remove_from_graph!(graph::TriGraph{T}, vertex::T)::Array{T, 1} where T

# Arguments
- graph::TriGraph{T}: triangle connectivity graph
- vertex::T: query triangle

# Returns
- nothing : removes vertex from the graph

# Note
- may leave dangling edges behind.
"""
function remove_from_graph!(graph::TriGraph{T}, vertex::T) where T
    delete!(graph.graph, vertex)
end


"""
create_triangle_graph(tri::DelaunayTriangulation.Triangulation)

Determines the triangle connectivity and the triangle pair--side mapping
to create a triangulation graph.

# Arguments
- tri::DelaunayTriangulation.Triangulation: triangulation

# Returns
- graph::DictGraph: traingle connectivity
- mapping_triangle_edge::Dict{Tuple{Int, Int}, Tuple{Int, Int}}: triangle pair--side mapping
"""
function create_triangle_graph(
        tri::DelaunayTriangulation.Triangulation
    )

    bookkeep_triangle = Dict{Set{Int}, Int}()
    mapping_triangle_edge = Dict{Tuple{Int, Int}, Tuple{Int, Int}}()
    graph = DictGraph{Int}()
    
    for (s, t) in DelaunayTriangulation.get_edges(tri)

        # ignore ghost edges
        if s < 1 || t < 1
            continue
        end
    
        # 1st triangle
        u = DelaunayTriangulation.get_adjacent(tri.adjacent, s, t)
        if u <  1
            continue
        end

        # 2nd triangle
        v = DelaunayTriangulation.get_adjacent(tri.adjacent, t, s)
        if v < 1
            continue
        end

        # number the triangles
        i1 = get!(bookkeep_triangle, Set([s, t, u]), length(bookkeep_triangle) + 1)
        i2 = get!(bookkeep_triangle, Set([s, t, v]), length(bookkeep_triangle) + 1)

        # add triangles to the graph
        push!(graph, i1, i2)
        push!(graph, i2, i1)

        # triangle pair -- side mapping (for plotting)
        push!(mapping_triangle_edge, order_two(i1, i2) => order_two(s, t))

    end

    triangles = Array{Int, 2}(undef, 3, length(bookkeep_triangle))

    for ((s, t, u), i) in bookkeep_triangle
        triangles[1, i] = s
        triangles[2, i] = t
        triangles[3, i] = u
    end

    return graph, mapping_triangle_edge, triangles

end

Base.length(graph::TriGraph) = length(graph.graph)

Base.in(vertex, graph::TriGraph) = haskey(graph.graph, vertex)
