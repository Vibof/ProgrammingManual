"""
Модуль  FindMarker экспортирует функцию find_marker!
осуществляющей поиск маркера на неограниченном поле при возможном наличии на нём перегородок в виде отрезков
"""
module FindMarker
    export find_marker!

    using HorizonSideRobots
    include("../8/horizonside.jl")
    include("functional_robot.jl")


    """
    find_marker!()

    перемещает Робота, находящегося где-то на неораниченном поле без внутренних перегородок, в клетку с маркером        
    """
    function find_marker!(robot)
        robot = interface_protected_robot(robot)
        rectangular_borders = interface_rectangular_borders(robot)

        function move_ifnomarker!(side)::Bool
            if robot.ismarker()
                return false
            end
            rectangular_borders.move!(side) # - return true
        end
        
        trajectories = interface_trajectories(robot)
        trajectories.spiral!(move_ifnomarker!)
    end
end

# ------- Исполняемая часть файла
using HorizonSideRobots
using .FindMarker
robot = Robot("9/example_9.2.sit"; animate=true)
FindMarker.find_marker!(robot)
