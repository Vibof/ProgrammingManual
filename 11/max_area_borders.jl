module NumBorders
    export get_max_area!

    include("../10/horizonside.jl")
    include("../10/functional_robot.jl")
    include("interface_borders_area.jl")


    function get_max_area!(robot)
        robot = interface_save_robot(robot)
 
        borders_area = interface_borders_area(robot, Nord)
        rectangular_borders = interface_rectangular_borders(robot)       
        trajectories = interface_trajectories(robot)
 
        max_area = 0

        trajectories.snake!(Ost, Nord) do side
            if robot.isborder(Nord) 
                return false 
            end 
            while borders_area.move!(side) || rectangular_borders.move!(side)
                area = borders_area.get_area()
                if area > max_area
                    max_area = area
                end
            end
        end
        
       return max_area
    end
end # module NumBorders

#-------Исполняемая часть файла

using .NumBorders
using HorizonSideRobots

#robot = Robot("11/horizontal_borders.sit", animate=true)
robot = Robot("11/rectangular_borders.sit", animate=true)
get_max_area!(robot) |> println