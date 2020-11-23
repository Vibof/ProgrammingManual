module ChessMarker
    export chess_mark!

    include("horizonside.jl")
    include("functional_robot.jl")
    include("interface_decart.jl")
    include("interface_robot_decart.jl")
    include("_chess_marker.jl")
end

#---------------Test:
using .ChessMarker
using HorizonSideRobots
r=Robot(animate=true)

chess_mark!(r)