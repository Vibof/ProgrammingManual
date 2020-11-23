module MarkersCounter
    export markers_counter!

    using HorizonSideRobots
    include("horizonside.jl")
    include("functional_robot.jl")

    function markers_counter!(robot)
        # Робот - в юго-западном углу
        robot = interface_protected_robot(robot)
        line = interface_line(robot.move!)
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

robot = Robot("8/example_8.2.sit", animate=true)
MarkersCounter.markers_counter!(robot) |> println
