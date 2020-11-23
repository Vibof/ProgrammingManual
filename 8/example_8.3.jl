"""
Модуль  FindMarker экспортирует функцию find_marker!
осуществляющей поиск маркера на неограниченном поле при отсутствии на нём перегородок
"""
module FindMarker
    export find_marker!

    using HorizonSideRobots
    include("horizonside.jl")
    include("functional_robot.jl")


    """
    find_marker!()

    перемещает Робота, находящегося где-то на неораниченном поле без внутренних перегородок, в клетку с маркером        
    """
    function find_marker!(robot)
        robot = interface_protected_robot(robot)

        function move_ifnomarker!(side)::Bool
            if robot.ismarker()
                return false
            end
            robot.move!(side) # - return true
        end
        
        trajectories = interface_trajectories(robot)
        trajectories.spiral!(move_ifnomarker!)
    end
end

# ------- Исполняемая часть файла
using HorizonSideRobots
using .FindMarker
robot = Robot("8/example_8.3.sit"; animate=true)
FindMarker.find_marker!(robot)
