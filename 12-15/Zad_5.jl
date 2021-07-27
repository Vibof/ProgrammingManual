module Zad5
    using HorizonSideRobots
    include("robot_types.jl")
    include("horizonside.jl")
    include("horizonside_robot.jl")


    function start!(r::Robot) # главная функция, 
        robot_path = RobotPath{Robot}(r)
        while !isborder(robot_path, Sud) || !isborder(robot_path, West)
            movements!(robot_path, Sud)
            movements!(robot_path, West)
        end
            #ygol!(r,Nord)
            #ygol!(r,Ost)
            #ygol!(r,Sud)
            #ygol!(r,West)
        movements_to_back!(robot_path)
    end

end

Zad5.start!(r)
