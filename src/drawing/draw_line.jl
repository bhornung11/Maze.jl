"""
Line drawing functions.
"""

import SimpleDraw as SD

export draw_lines_on_bitmap
export draw_lines_on_bitmap!

"""
draw_lines_on_bitmap(
        height::Int, width::Int, lines::Array{Int, 2},  width_line::Int
)::Array{Int, 2}


Creates a bitmap of lines.

# Arguments
- height::Int : image height
- width::Int : image width
- lines::Array{Array{Int, 1}, 1} : lines
    - (x1, y1) -> (x2, y2)
- width_line::Int : line width

# Returns
- img::Array{Int, 2} : bitmap
"""
function draw_lines_on_bitmap(
        height::Int,
        width::Int,
        lines::Array{Array{Int, 1}, 1},
        width_line::Int
    )::Array{Int, 2}

    # initialise the canvas
    img = trues(height, width)

    # loop over all lines
    for (x1, y1, x2, y2) in lines
        # make the line
        line = SD.ThickLine(SD.Point(x1, y1), SD.Point(x2, y2), width_line)

        # draw the line on the canvas
        SD.draw!(img, line, false)
    end

    return img
end

function draw_lines_on_bitmap!(
    bitmap::BitMatrix,
    lines::Array{Array{Int, 1}, 1},
    width_line::Int
)

    # loop over all lines
    for (x1, y1, x2, y2) in lines
        # make the line
        line = SD.ThickLine(SD.Point(x1, y1), SD.Point(x2, y2), width_line)

        # draw the line on the canvas
        SD.draw!(bitmap, line, false)
    end

end
