"""
Border graph drawing utilities.
"""

using Colors
using SimpleDraw


function draw_decomposition_triangles_filled!(
        graph::TriGraph{T},
        labels::Dict{T, Int},
        xy::Array{T, 2},
        canvas,
        mapping_colour::Dict{Int, RGB{N0f8}}
    ) where T

    # scratch area
    scratch = zeros(Bool, 1300, 1300)

    # extract triangle coordinates
    for (i_tri, idcs) in enumerate(eachcol(graph.triangles))
        xy_ = xy[:, idcs]

        # get label
        label = labels[i_tri]

        # look up colour
        colour = mapping_colour[label]

        # draw a single triangle
        draw_filled_triangle!(xy_, canvas, scratch, colour)

        # erase scratch area
        scratch .= false
    end
end


function draw_filled_triangle!(
        xy::Array{Int, 2},
        canvas::Array{RGB{N0f8}, 2},
        scratch::Array{Bool, 2},
        colour::RGB{N0f8},
    )

    # translate triangle to the origin
    mins = minimum(xy; dims=2) 
    maxs = maximum(xy; dims=2)
    shifted = xy .- mins .+ 1

    # create a mask on the scratch area
    p1 = Point(shifted[1, 1], shifted[2, 1])
    p2 = Point(shifted[1, 2], shifted[2, 2])
    p3 = Point(shifted[1, 3], shifted[2, 3])
    shape = FilledTriangle(p1, p2, p3)

    draw!(scratch, shape, true)

    # translate the mask back and colour pixels
    for i in 1:maxs[1] + 1 - mins[1]
        for j in 1:maxs[2] + 1 - mins[2]
            if scratch[i, j]
                canvas[i + mins[1] - 1, j + mins[2] - 1] = colour
            end
        end
    end

end


function draw_triangles_frame(
    graph::TriGraph,
    xy::Array{Int, 2},
    canvas,
    width::Int,
    colour::RGB{N0f8}
)

size_canvas = size(canvas)

scratch = zeros(Bool, size_canvas)

# extract all lines to make a mask
for (i1, i2, i3) in eachcol(graph.triangles)
    line = ThickLine(Point(xy[1, i1], xy[2, i1]), Point(xy[1, i2], xy[2, i2]), width)
    draw!(scratch, line, true)
    line = ThickLine(Point(xy[1, i1], xy[2, i1]), Point(xy[1, i3], xy[2, i3]), width)
    draw!(scratch, line, true)
    line = ThickLine(Point(xy[1, i2], xy[2, i2]), Point(xy[1, i3], xy[2, i3]), width)
    draw!(scratch, line, true)
end

# apply mask to canvas
canvas[scratch .== true] .= colour
end


function draw_borders!(
        borders::Array{Array{Int, 2}, 1},
        canvas::Array{RGB{N0f8}, 2},
        width::Int,
        colour::RGB{N0f8}
    )

    size_canvas = size(canvas)

    scratch = zeros(Bool, size_canvas)

    for border in borders
        draw_border!(border, canvas, scratch, width, colour)
        scratch .= false
    end
end


function draw_border!(
        xy::Array{Int, 2},
        canvas::Array{RGB{N0f8}, 2},
        scratch::Array{Bool, 2},
        width::Int,
        colour::RGB{N0f8}
    )

    # create a mask
    n = size(xy)[2]

    for i in 1:n

        x1, y1 = xy[:, i]
        i2 = (i + 1) % n
        i2 = i2 == 0 ? n : i2
        x2, y2 = xy[:, i2]
        line = ThickLine(Point(x1, y1), Point(x2, y2), width)
        draw!(scratch, line, true)
    end

    canvas[scratch .== true] .= colour

end
