"""
Ordering utilities
"""

"""
    order_two(a::Int, b::Int)::Tuple{Int, int}

Arranges two integers in ascending order.

# Arguments
- a::Int
- b::Int

# Returns
- `::Tuple{Int}` the ordered integers
"""
function order_two(a::Int, b::Int)::Tuple{Int, Int}
    if a <= b
        return a, b
    end
    return b, a
end