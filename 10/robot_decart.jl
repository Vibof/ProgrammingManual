include("../8/horizonside.jl")
function interface_decart(x,y)
    function decart(side::HorizonSide)
        if side == Ost
            x+=1
        elseif side == West
            x-=1
        elseif side == Nord
            y+=1
        else
            y-=1
        end
        (x=x,y=y)
    end
    decart() = (x=x,y=y)
    return (decart = decart,)
end

mutable struct RobotDecart <: AbstractRobot
    robot::Robot
    coordinates::NamedTuple{(:x,:y),NTuple{2,Int}}
    decart::NTuple{1,Functional}
    RobotDecart(robot::Robot,coordinates::NamedTuple{(:x,:y),NTuple{2,Int}}) = new(robot,coordinates,interface_decart(Tuple(coordinates)...))
end

function move!(robot::RobotDecart,side)
    robot.coordinates = robot.decart(side)
    move!(AbstractRobot(robot), side)
end