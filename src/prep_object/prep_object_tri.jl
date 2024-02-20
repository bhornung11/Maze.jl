"""
Point samplin utilities for Delaunay graphs.
"""


using DataStructures
using NearestNeighbors


include("../graphs/graph_dict.jl")


export sample_drawing_points_2d


"""
sample_drawing_points_2d(
        n_point::Int
        height_canvas::Int,
        width_canvas::Int,
        width_line::Int,
        factor_opening::Int
    )

Samples points in a rectangle and attempts to ensure that all pairs
can be drawn clearly.

# Arguments
- height_canvas::Int: height of the canvas in pixels
- width_canvas::Int: width of the canvas in pixels
- width_line::Int: width of the line in pixels
- factor_opening::Int: minimum required distance between points in line width

# Returns
- points::Array{Int, 2}: points
"""
function sample_drawing_points_2d(
        n_point::Int,
        height_canvas::Int,
        width_canvas::Int,
        width_line::Int,
        factor_opening::Int
    )
    
    # calculate maximum number of points
    n_point_max = calc_drawing_points_sample_size_2d(
        height_canvas, width_canvas, width_line, factor_opening
    )

    # limit the number of points if needed
    n_point = n_point_max < n_point ? n_point_max : n_point

    # sample
    points = [
        reshape(rand(1:height_canvas, n_point), 1, :);
        reshape(rand(1:width_canvas, n_point), 1, :)
    ]

    # make neighbour graph
    graph_neighbour = create_neighbour_graph(points, width_line * factor_opening)

    # identify points to remove
    points_to_remove = thin_graph(graph_neighbour, 0)

    # remove the points
    points = points[:, setdiff(1:end, points_to_remove)]
end


"""
thin_graph(graph::DictGraph{T}, max_degree::Int) where T

Remove vertices from the graphs until the maximum degree is not greater
than a limit.

# Arguments
- graph::DictGraph{T}: graph
- max_degree::Int: maximum allowed degree

# Returns
- to_remove:Array{T, 1}: vertices to remove
"""
function thin_graph(graph::DictGraph{T}, max_degree::Int) where T

    # vertex degree mapping
    degrees = Dict(
        vertex => length(get_neighbours(graph, vertex))
        for vertex in get_vertices(graph)
    )
    # select vertices which are in more than the allowed edges
    degrees = Dict(
        vertex => degree for (vertex, degree) in degrees if degree > max_degree
    )
    vertices = collect(keys(degrees))
    degrees = [degrees[vertex] for vertex in vertices]

    # sort the selected vertices in descending order acc. to their degrees
    idcs = sortperm(degrees, rev=true)
    degrees = OrderedDict(zip(vertices[idcs], degrees[idcs]))

    # remove vertices -- one pass is enough
    to_remove = Set{T}()
    for (s, _) in degrees
        
        # explicit vertex deletion
        # for some reason, we need to reference `degrees`
        # otherwise the vertex is not deleted
        if haskey(degrees, s)
            delete!(degrees, s)
            push!(to_remove, s)
        end

        # implicit vertex deletion through edges
        for t in get_neighbours(graph, s)
            if haskey(degrees, t)
                deg_curr = degrees[t] -= 1
                if deg_curr <= max_degree
                    delete!(degrees, t)
                end
            end
        end
    end

    collect(to_remove)
end


"""
create_neighbour_graph(points::Array{Int, 2}, radius::Int)::DictGraph{Int}

Constructs a graph where an edge is draw between two points/vertices
if they are closer to each other than a given distance.

# Arguments
- points::Array{Int, 2}: 2D point set
- radius::Int: distance below which an edge is drawn

# Returns
- unnamed::DictGraph{Int}: graph
"""
function create_neighbour_graph(
        points::Array{Int, 2},
        radius::Int
    )::DictGraph{Int}

    tree = KDTree(points * 1.0)
    idcs = inrange(tree, points, radius)

    graph = Dict{Int, Array{Int, 1}}()

    # filter out identities (distance = 0)
    for (vertex, neighbours) in enumerate(idcs)
        push!(graph, vertex => collect(filter(x -> x != vertex, neighbours)))
    end

    # create a dictionary based graph
    DictGraph(graph)

end


"""
calc_drawing_points_sample_size_2d(
        height_canvas::Int,
        width_canvas::Int,
        width_line::Int,
        factor_opening::Int,
        prob_rejection::Float64=0.01
    )::Int

Calculates how many point can at maximum be samples in a rectangle
so that drawing lines between them does not lead to false enclosed areas
due to finite resolution.

# Arguments
- height_canvas::Int: height of the canvas in pixels
- width_canvas::Int: width of the canvas in pixels
- width_line::Int: width of the line in pixels
- factor_opening::Int: minimum required distance between points in line width
- prob_rejection::Float64=0.01: ratio of points rejected from the initial sample

# Returns
- n::Int: number of points to sample
"""
function calc_drawing_points_sample_size_2d(
        height_canvas::Int,
        width_canvas::Int,
        width_line::Int,
        factor_opening::Int,
        prob_rejection::Float64=0.05
    )::Int

    denom = factor_opening * width_line
    factor = height_canvas * width_canvas / (denom * denom)

    n = - factor * (log(exp(1), 1 - prob_rejection)) / pi
    n = ceil(Int, n)
end
