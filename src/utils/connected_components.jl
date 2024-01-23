"""
label_connected_components_image!(x::Array{Int, 2}, val::Int)

Hohsen--Kopelman connected component labeling algorithm. Only the background
is labeled.

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

    equivs = DictGraph{Int}()

    label = 0
    # leftmost column to save `if`-s
    if x[1, 1] != foreground
        label -= 1
        x[1, 1] = label
        push!(equivs, -1)
    end

    for i in 2:n_row
        prev = x[i - 1, 1]

        if x[i, 1] == foreground
            continue
        end

        if prev == foreground
            # new label
            label -= 1
            x[i, 1] = label
            push!(equivs, label)
        else
            # the previous is background too --> propagate label
            x[i, 1] = prev
        end

    end

    # topmost row to save `if`-s
    for j in 2:n_col
        prev = x[1, j - 1]

        if x[1, j] == foreground
            continue
        end

        if prev == foreground
            label -= 1
            x[1, j] = label
            push!(equivs, label)
        else
            x[1, j] = prev
        end
    end


    # 1st pass -- label contiguous background pixels
    for j in 2:n_col
        for i in 2:n_row

            # foreground keeps its label
            if x[i, j] == foreground
                continue
            end

            north = x[i - 1, j]
            west = x[i, j - 1]

            if west == foreground
                if north == foreground
                    # not connected to background from the top and left --> propagate label
                    x[i, j] = label -= 1
                    # label is equivalent to itself
                    push!(equivs, label)
                else
                    # top is background --> use its label
                    x[i, j] = north
                end
            else
                if north == foreground
                    # only the left is background --> use tis label
                    x[i, j] = west
                else
                    # both top and left are background --> use the larger label
                    x[i, j] = north > west ? north : west
                    # save connections
                    push!(equivs, north, west)
                    push!(equivs, west, north)
                end
            end
        end
    end

    # by now, a pixel either has a foreground value
    # or a negative label starting at minus one

    # preps for the 2nd pass
    # the label equivalence classes from a graph where each connected component
    # is a set of labels which are adjacent in the image
    # we create a mapping where the image labels point to the index
    # of the connected component they belong to
    labels = Dict{Int, Int}()
    for (i_component, component) in enumerate(
        get_connected_components(equivs)
    )
        for label in component
            push!(labels, label => - i_component)
        end
    end

    # apply label equivalences
    for j in 1:n_col
        for i in 1:n_row
            if (current = x[i, j]) != foreground
                x[i, j] = labels[current]
            end
        end
    end

    # set foreground to zero
    if foreground == 0
        return
    end

    for i in 1:n_col
        for j in 1:n_row
            if x[i, j] == 1
                x[i, j] = 0
            end
        end
    end

end
