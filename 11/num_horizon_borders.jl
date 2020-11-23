module NumBorders
    export get_num_borders!

    include("../10/horizonside.jl")
    include("../10/functional_robot.jl")
    include("interface_fold_borders_counter.jl")

    function get_num_borders!(robot)
        robot = interface_save_robot(robot)

        horizont_borders_counter = interface_fold_borders_counter(robot, Nord)
        trajectories = interface_trajectories(robot)

        trajectories.snake!(Ost, Nord) do side
            if robot.isborder(Nord)
                return false
            end
            while horizont_borders_counter.move!(side) || robot.move!(side)
            end
        end

       return horizont_borders_counter.get_num()
    end
end # module NumBorders

#-------Исполняемая часть файла:
using .NumBorders
using HorizonSideRobots

robot = Robot("11/horizontal_borders.sit", animate=true)

get_num_borders!(robot) |> println
