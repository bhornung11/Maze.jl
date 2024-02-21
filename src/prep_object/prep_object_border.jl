"""
Border graph obejct preparation utilities.
"""

export trim_in_ellipse

"""
function trim_in_ellipse(x::Array{T, 2}, x_c::T, y_c::T, r_x::T, r_y::T) where T

Trims a pointset with an axis-aligned ellipse.

# Arguments
- `x::Array{T, 2}` : points
- `x_c::T` : ordinate of the centre of the ellipse
- `y_c::T` : abcissa of the centre of the ellipse
- `r_x::T` : 1st semi-axis of the ellipse
- `r_y::T` : 2nd semi-axis of the ellipse

# Returns
- `trimmed::Array{T, 2}` : points inside of an ellipse
"""
function trim_in_ellipse(x::Array{T, 2}, x_c::T, y_c::T, r_x::T, r_y::T) where T

    n, m = size(x)

    if n != 2
        throw(
            ArgumentError("First dimension must equal to 2. Got: $(n)")
        )
    end

    trimmed = Array{T}(undef, n, m)

    k = 0

    for i in 1:m
    x_ = x[1, i]
    y_ = x[2, i]
        is_inside = is_in_ellipse(x_, y_, x_c, y_c, r_x, r_y)
        if is_inside
            k += 1
            trimmed[1, k] = x_
            trimmed[2, k] = y_
        end
    end

    return trimmed[1:2, 1:k]

end


"""
function is_in_ellipse(x::T, y::T, x_c::T, y_c::T, r_x::T, r_y::T) where T
Decides whether a point is inside of an ellipse. Points falling on the ellipse contour are considered being inside.

# Arguments

- x::T : abcissa of the trial point
- y::T : oordinate of the trial point
- x_c::T : abcissa of the centre of the ellipse
- y_c::T : oordinate of the centre of the ellipse
- r_x::T : length of the 1st semi-axis
- r_x::T : length of the 2nd semi-axis


# Returns
- is_inside::Bool : 
"""
function is_in_ellipse(x_c::T, y_c::T, r_x::T, r_y::T, x::T, y::T) where T

    frac_1 = (x - x_c) / r_x
    frac_2 = (y - y_c) / r_y
 
    dist = frac_1 * frac_1 + frac_2 * frac_2

    is_inside = dist <= 1

end
