module Maze

# misc
include("utils/connected_components.jl")
include("utils/grid.jl")
include("utils/images.jl")
include("utils/kmeanspp.jl")
include("utils/shape_file.jl")

# objects
include("graphs/graph.jl")
include("graphs/graph_dict.jl")
include("graphs/graph_image_border_component.jl")
include("graphs/graph_image_grid_component.jl")
include("graphs/graph_rectangle.jl")
include("graphs/graph_tri.jl")

# object preparation
include("prep_object/prep_object_border.jl")
include("prep_object/prep_object_tri.jl")

# link generation
include("algorithm/decompose.jl")
include("algorithm/random_walk.jl")

# drawing prepapation
include("prep_drawing/prep_drawing_border.jl")
include("prep_drawing/prep_drawing_image_component.jl")
include("prep_drawing/prep_drawing_rectangle.jl")
include("prep_drawing/prep_drawing_triangle.jl")


# rendering
include("drawing/draw_line.jl")
include("drawing/draw_rectangle.jl")
include("drawing/draw_image_grid_component.jl")

end