using Random
using StatsBase


export select_sides_to_omit_component


"""
select_sides_to_omit_component(
        x::Array{Int, 2},
        links::Array{Int, 2}
)

Identifies those sides of the grid rectangles which are not rendered

# Arguments
- x::Array{Int, 2}: labeled image components and grid rectangles
    - the components must have negative labels
- links::Array{Int, 2}: connectivity between grid rectangles and components
    - each colum: target < source

# Returns
- graph::Dict{Int, Array{Int, 1}} indices of grid rectangle sides
    which are not rendered
"""
function select_sides_to_omit_component(
        x::Array{Int, 2},
        links::Array{Int, 2}
    )
    n_row, n_col = size(x)
    grid = RectangleGraph(n_row, n_col)

    sides_to_omit = DictGraph{Int}()

    # loop over all links to find connecting sides
    # `source` is always a grid rectangle
    for (target, source) in eachcol(links)

        # if both are grid rectangles
        if source >= 1 && target >= 1
            
            # get at which (N/E/S/W) sides the two grid rectangles meet
            side_source, side_target = get_shared_sides_rectangle(
                source, target, n_row
            )

            # save which side will need not be rendered
            push!(sides_to_omit, source, side_source)
            push!(sides_to_omit, target, side_target)

        # `source` is a grid rectangle, `target` is a component
        elseif source >= 1 && target < 0

            # the neighbours are given in grid 1D indices
            for neighbour in shuffle(get_neighbours(grid, source))
                    
                # choose the first neighbour which matches the index of the component
                if x[neighbour] == target
                    side_source, side_target = get_shared_sides_rectangle(
                        source, neighbour, n_row
                    )
                    # only save the grid rectangle side
                    # (components are rendered indirectly)
                    push!(sides_to_omit, source, side_source)
                    break
                end
            end
        else
            throw(ErrorException("something"))
        end

    end

    return sides_to_omit.graph

end
