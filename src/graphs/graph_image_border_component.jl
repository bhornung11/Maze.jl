"""
Yet an other graph class.
"""


export ImageBorderComponentGraph


"""
`ImageBorderComponentGraph{Int} <:Graph{Int}`

Graph composed of image components which are separated by borders.
"""
struct ImageBorderComponentGraph{Int} <:Graph{Int}
    """`graph::DictGraph{Int}`: component connectivity"""
    connectivity::DictGraph{Int}
    """`mapping::Dict{Tuple{Int, Int}, Array{CartesianIndices, 1}}`: component pair--border pixel mapping"""
    mapping::Dict{Tuple{Int, Int}, Array{CartesianIndices, 1}}
    """`image_components::Array{Int, 2}`: 2D array of labeled image components"""
    image_components::Array{Int, 2}
    """`foreground::Int`: value to mark foreground pixels"""
    foreground::Int
end


"""
ImageBorderComponentGraph(
    image_components::Array{Int, 2}, foreground::Int, width_line::Int
)

Creates an image component graph where the component are separated by a border
of given width.

# Arguments
- `image_components::Array{Int, 2}`: labelled image components
- `foreground::Int`: value to mark the foreground
- `width_line::Int`: line width

# Returns
- `graph::ImageBorderComponentGraph`: graph
"""
function ImageBorderComponentGraph(
        image_components::Array{Int, 2},
        foreground::Int,
        width_line::Int
    )

    connectivity, mapping = get_image_border_connectivity(
        image_components, foreground, width_line
    )

    ImageBorderComponentGraph(
        connectivity, mapping, image_components, foreground
    )
end


"""
get_neighbours(graph::ImageBorderComponentGraph, vertex::Int)

Gets the components separated by a single border from the query component.

# Arguments
- `graph::ImageBorderComponentGraph`: graph
- `vertex::Int`:component (vertex)

# Returns
- `unnamed::Array{Int, 1}`: components separated by a single border from the query component
"""
function get_neighbours(graph::ImageBorderComponentGraph, vertex::Int)
    get_neighbours(graph.connectivity, vertex)
end

"""
get_vertices(graph::ImageBorderComponentGraph)

Gets all components.

# Arguments
- `graph::ImageBorderComponentGraph`: graph

# Returns
- `unnamed::Array{Int, 1}`:all components
"""
function get_vertices(graph::ImageBorderComponentGraph)
    get_vertices(graph.connectivity)
end


"""
get_image_border_connectivity(image::Array{Int, 2}, foreground::Int, width_line::Int)

Finds the connectivity of image components defined by foreground borders.

# Arguments
- `image::Array{Int, 1}`2D array of labeled image components
- `foreground::Int`: value to mark foreground pixels
- `width_line::Int`: line width that marks the foreground

# Returns
- `connectivity::DictGraph{Int}`: connectivity of labelled components
- `mapping::Dict{Tuple{Int, Int}, Array{CartesianIndices, 1}}`:
    component pair--border pixel mapping
"""
function get_image_border_connectivity(
        image::Array{Int, 2},
        foreground::Int,
        width_line::Int
    )

    connectivity = DictGraph{Int}()

    mapping = Dict{Tuple{Int, Int}, Array{CartesianIndices, 1}}()

    n_row, n_col = size(image)
    shift = width_line + 1
    for j in shift + 1:n_col
        for i in shift + 1:n_row
            if (current = image[i, j]) == foreground
                continue
            end

            north = image[i - shift, j]
            west = image[i, j - shift]

            if north != current && north != foreground
                push!(connectivity, current, north)
                push!(connectivity, north, current)  

                pair = order_two(current, north)
                if !haskey(mapping, pair)
                    push!(mapping, pair => [CartesianIndices((i-width_line:i-1, j:j))])
                else
                    push!(mapping[pair], CartesianIndices((i-width_line:i-1, j:j)))
                end
            end

            if west != current && west != foreground
                push!(connectivity, current, west)
                push!(connectivity, west, current)  

                pair = order_two(current, west)
                if !haskey(mapping, pair)
                    push!(mapping, pair => [CartesianIndices((i:i, j-width_line:j-1))])
                else
                    push!(mapping[pair], CartesianIndices((i:i, j-width_line:j-1)))
                end
            end
            
        end
    end

    return connectivity, mapping
end
