"""
Модуль содержит определение функции markers_counter!(), 
возвращающей число маркеров внутри простого лабирина, содержащего внутри себя изолированные 
пергородки прямоугольной формы.
Требуется, чтобы изначально Робот находился в левом нижнем углу лабиринта.
В исходное положение Робот не возвращается 
"""
module MarkersCounter
    export markers_counter!

    using HorizonSideRobots
    include("../8/horizonside.jl")
    include("functional_robot.jl")

    function markers_counter!(robot)
        # Робот - в юго-западном углу
        robot = interface_protected_robot(robot)
        rectangular_borders = interface_rectangular_borders(robot)
        line = interface_line(rectangular_borders.move!)
        trajectories = interface_trajectories(robot)

        counter() = if robot.ismarker() num_markers+=1 end
        
        num_markers = 0
        trajectories.labirint_snake!(Ost, Nord) do side
            counter()
            line.movements!(counter, side)
            return true
        end

        return num_markers
    end

end # module MarkersCounter

#-------------------------- Исполняемая часть файла

using HorizonSideRobots
using .MarkersCounter

robot = Robot("9/example_9.1.sit", animate=true)
MarkersCounter.markers_counter!(robot) |> println
