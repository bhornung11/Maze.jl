"""
Preps and posts.
"""

using Colors

export colour_labeled_image
export extract_coords


"""
function colour_labeled_image(img_labels::Array{Int, 2})
"""
function colour_labeled_image(img_labels::Array{Int, 2})
    colourmap = colormap("Blues", 5000)
    mask = @. ifelse(img_labels < 0, - img_labels % 5000, 1)
    img_coloured = colourmap[mask]
    img_coloured[img_labels .== 0] .= RGB(0,0,0)
    return img_coloured
end


"""
function extract_coords(x::Array{Int, 2}, val::Int)

Extracts the coordinates of the elements which are 
equal to a value.

# Arguments
- x::Array{Int, 2} : 2D image
- val::Int : value sought

# Returns
- xy::Array{Int, 2} : coordinates
"""
function extract_coords(x::Array{Int, 2}, val::Int)

    n_row, n_col = size(x)
    
    # avoid repated allocation on the expense of
    # two passes in total
    n_xy = sum(el == val for el in x)
    xy = zeros(Int, (2, n_xy))
    
    k = 1
    for j in 1:n_col
        for i in 1:n_row
            if x[i, j] == val
                xy[:, k] .= i, j
                k += 1
            end
        end
    end
    return xy
end
