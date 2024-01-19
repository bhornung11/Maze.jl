"""
Structure to handle sets of points.
"""


"""
Structure to store blocks of 2D coordinates.
"""
struct PointSets{T}
    """`points::Array{T, 2}`: coordinates"""
    points::Array{T, 2}
    """`segments::Array{Int, 2}`: start and end indices of coordinate blocks"""
    segments::Array{Int, 2}
    """`n_set::Int`: number of blocks"""
    n_set::Int
end


"""
PointSets(point_sets::PointSets{T}, S) where T

Typecast point sets.
"""
function PointSets(point_sets::PointSets{T}, S) where T
    PointSets(
        S.(round.(point_sets.points, digits=0)),
        point_sets.segments,
        point_sets.n_set
    )
end


"""
PointSets(point_sets::Array{Array{T, 2}, 1}) where T

# Arguments
- `point_sets::Array{Array{T, 2}, 1}`: block of coordinates

# Returns
- `::PointSets`: container storing all points.
"""
function PointSets(point_sets::Array{Array{T, 2}, 1}) where T

    n_set = length(point_sets)
    sizes = [size(point_set)[2] for point_set in point_sets]
    n_point_all = sum(sizes)
    
    points = zeros(T, (2, n_point_all))
    segments = zeros(Int, (2, n_set)) 

    i2 = 0
    for (i, point_set) in enumerate(point_sets)

        i1 = i2 + 1
        i2 = i1 + sizes[i] - 1

        points[:, i1:i2] .= point_set
        segments[1, i] = i1
        segments[2, i] = i2

        i1 = i2
        
    end
    PointSets(points, segments, n_set)
end


Base.getindex(P::PointSets, i::Int) = begin
    P.points[:, P.segments[1, i]:P.segments[2, i]]
end


Base.iterate(P::PointSets, state=1) = begin
    state > P.n_set ? nothing : (
        P.points[:, P.segments[1, state]:P.segments[2, state]],
        state += 1
    )
end


Base.length(P::PointSets) = size(P.points)[2]
