"""
Dictionary graph.
"""


import Base: push!

export DictGraph
export decompose_graph
export get_neighbours
export get_vertices


"""
DictGraph{T} <: Graph{T}

Dictionary graph.
- keys : vertices
- values: vertices connected to the keys as an array 
"""
struct DictGraph{T} <: Graph{T}
    graph::Dict{T, Array{T, 1}}
end


"""
DictGraph{T}() where T

Creates an empty dictionary graph
"""
function DictGraph{T}() where T
    DictGraph{T}(Dict{T, Array{T, 1}}())
end


"""
push!(dict_graph::DictGraph{T}, source::T, target::T) where T

Adds an edge to the graph.

# Arguments
- dict_graph::DictGraph{T}: graph
- source::T: source vertex
- target::T: target vertex

# Returns
- nothing: modified the graph in-place
"""
function push!(dict_graph::DictGraph{T}, source::T, target::T) where T
     if (targets = get(dict_graph.graph, source, nothing)) !== nothing
        if !(target in targets)
            push!(dict_graph.graph[source], target)
        end
    else
        push!(dict_graph.graph, source => [target])
    end
end


function push!(dict_graph::DictGraph{T}, source::T) where T
    if !haskey(dict_graph.graph, source)
        push!(dict_graph.graph, source => Array{T, 1}())
    end
end

"""
get_vertices(graph::DictGraph{T}) where T

Returns all vertices of the graph.

# Arguments
- graph::DictGraph{T}: graph

# Returns
- unnamed::Array{T, 1}: vertices (unordered)
"""
function get_vertices(graph::DictGraph{T}) where T
    collect(keys(graph.graph))
end


"""
get_neighbours(graph::DictGraph{T}, vertex::T) where T

Retrieves the neighbours of a vertex of the graph.

# Parameters
- graph::DictGraph{T}: graph
- vertex::T: vertex

# Returns
- unnamed::Array{T, 1}: neighbouring vertices
"""
function get_neighbours(graph::DictGraph{T}, vertex::T) where T
    return graph.graph[vertex]
end


"""
Decomposes a graph in terms of dictionary graphs.
"""
function decompose_graph(graph::Graph)::Array{Graph}

    components = Array{Graph, 1}()

    # copy largest component
    vertex_groups = get_connected_components(graph)

    # sort by decreasing length
    idcs = sortperm([length(component) for component in vertex_groups], rev=true)

    # recreate components with the full connectivity
    for i in idcs
        component = DictGraph{Int}()

        for source in vertex_groups[i]
            for target in get_neighbours(graph, source)
                push!(component, source, target)
                push!(component, target, source)
            end
        end
        push!(components, component)
    end

    return components
end

Base.delete!(graph::DictGraph, vertex) = begin delete!(graph.graph, vertex) end

Base.length(graph::DictGraph) = length(graph.graph)

Base.haskey(graph::DictGraph, vertex) = haskey(graph.graph, vertex)
