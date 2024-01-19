"""
shape file utils.
"""


using GeoTables
using StatsBase


include("pointsets.jl")


export extract_borders_from_shapefile
export discretise_borders


"""
extract_borders_from_shapefile(pth::String)::PointSets

Extracts borders from a shape file.

# Arguments
- `pth::str`: full path to the shapefile

# Returns
- `::PointSets`: structure containing all borders as xy coordinates.
"""
function extract_borders_from_shapefile(pth::String)::PointSets

    table = GeoTables.load(pth)
    
    borders = Array{Matrix{Float64}, 1}()
    
    
    for mesh in table.geometry
        borders_ = extract_borders_from_mesh(mesh)
        append!(borders, borders_)
    end

    return PointSets(borders)
end


"""
extract_borders_from_mesh(mesh)

Extracts the border/polygon coordinates from a mesh.

# Arguments
- `mesh`: borders as native shapefile polygon structures

# Returns
- `borders::Array{Matrix{Float64}, 1}` : list of the borders.
    Each element is a 2D vector of the border points.
"""
function extract_borders_from_mesh(mesh)
    
    borders = Array{Matrix{Float64}, 1}()
    
    for geom in mesh.geoms
        
        border = Array{Float64, 2}(undef, 2, 0)
        for point in geom.outer.vertices.data
            (x, y) = point.coords
            border = hcat(border, [- y, x])
        end
        push!(borders, border)

    end

    return borders
end


"""
discretise_borders(borders::PointSets, width_canvas::Int, width_border_canvas::Int)

Transforms the borders coordinates to pixel coordinates.

# Arguments
- `borders::PointSets`: borders
- `width_canvas::Int`: canvas width
- `width_border_canvas::Int` : blank area width

# Returns
- `::PointSets`: borders with integer coordinates
"""
function discretise_borders(
    borders::PointSets,
    width_canvas::Int,
    width_border_canvas::Int
)

ranges = maximum(borders.points, dims=2) - minimum(borders.points, dims=2)
ranges = (r1 = ranges[1]) > (r2 = ranges[2]) ? ranges ./ r1 : ranges ./r2

StatsBase.transform!(
    fit(UnitRangeTransform, borders.points, dims=2),
    borders.points
)

borders.points .*= ((width_canvas - 2 * width_border_canvas) * ranges)
borders.points .+= [width_border_canvas, width_border_canvas]

PointSets(borders, Int)

end


function interpolate_cyclic(x::Array{Float64, 2})::Array{Float64, 2}

    n = size(x)[2]

    x_intp = ones(Float64, (2, 3 * n))

    for i in 1:n
        xy1 = x[:, i]
        xy2 = x[:, mod(i, n) + 1]
        x_intp[:, i * 3 - 2] = xy1
        x_intp[:, i * 3 - 1] = (2 * xy1 + xy2) / 3
        x_intp[:, i * 3] = (xy1 + 2 * xy2) / 3
    end
    x_intp
end
