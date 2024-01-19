"""
label_connected_components_image!(x::Array{Int, 2}, val::Int)

Hohsen--Kopelman connected component labeling algorithm.

# Arguments
- `x::Array{Int}` : image. All foreground pixels must be marked by the same non-negative value.
- `foreground::Int`: value t mark foreground pixels

# Returns
- nothing: modifies the image in-place
"""
function label_connected_components_image!(
    x::Array{Int, 2},
    foreground::Int
)

if foreground != 0 && foreground != 1
    throw(ArgumentError("`foreground` must be 0 or 1. Got: $(val)"))
end

n_row, n_col = size(x)

label = - 1
equivs = DictGraph{Int}()

# leftmost column to save `if`-s
if x[1, 1] != foreground
    x[1, 1] = label
end
prev = x[1, 1]
for i in 2:n_row
    if x[i, 1] != foreground
        if prev == foreground
            x[i, 1] = label -= 1
        else
            x[i, 1] = prev
        end
    end
end
# topmost row to save `if`-s
prev = x[1, 1]
for j in 2:n_col
    if x[1, j] != foreground
        if prev == foreground
            x[1, j] = label -= 1
        else
            x[1, j] = prev
        end
    end
end

# 1st pass -- label contiguous background pixels
for j in 2:n_col
    for i in 2:n_row

        if x[i, j] == foreground
            continue
        end

        north = x[i-1, j]
        west = x[i, j-1]

        if west == foreground
            if north == foreground
                x[i, j] = label -= 1
                push!(equivs, label)
            else 
                x[i, j] = north
            end
        else
            if north == foreground
                x[i, j] = west
            else
                x[i, j] = north < west ? north : west
                push!(equivs, north, west)
                push!(equivs, west, north)
            end
        end
    end
end

# preps for the 2nd pass
labels = Dict(
    i => - label - 1
    for (label, component) in enumerate(get_connected_components(equivs))
    for i in component
)

# apply label equivalences
for j in 1:n_col
    for i in 1:n_row
        if (current = x[i, j]) != foreground
            x[i, j] = labels[current]
        end
    end
end

end
