"""
Модуль  FindMarker экспортирует функцию
    find_marker!
осуществляющую поиск маркера на неограниченном поле, на которм могут находиться 
конечные или полубесконечные прямолинейные перегородки
"""
module FindMarker
    export find_marker!

    using HorizonSideRobots
    include("../8/horizonside.jl")
    include("functional_robot.jl")

    """
    find_marker!(robot::Robot)

    перемещает Робота, находящегося где-то на неограниченном поле без внутренних перегородок, 
    в клетку с маркером        
    """
    function find_marker!(robot::Robot)
        robot = interface_protected_robot(robot)
        line = interface_line(robot.move!)


        function move_ifnomarker!(side)::Bool
            if robot.ismarker()
                return false
            end
            move_unlimited_line!(side)
            return true
        end
    
        function move_unlimited_line!(side)
            coordinate = 0 # - текущая координата Робота относительно начального положения
            num_steps = 1 # - текущее число шагов при поиске края перегородки
            orthogonal = right(side) # - текущее направление поиска края перегородки
            back_side = orthogonal # - первоначальное направление поиска края перегородки
            while robot.isborder(side) # поиск края полубесконечной прямолинейной перегородки
                line.movements!(orthogonal,num_steps)
                if orthogonal == back_side 
                    coordinate += num_steps
                else
                    coordinate -= num_steps
                end
                num_steps+=1
                orthogonal=inverse(orthogonal)
            end
            #УТВ: Робот - за краем перегородки
            robot.move!(side)
            if coordinate > 0
                back_side = inverse(back_side)
            else
                coordinate = -coordinate
            end
            line.movements!(back_side,coordinate)
            #УТВ: Робот - в соседней, по отношению к исходной, позиции с другой стороны от перегородки
        end

        trajectories = interface_trajectories(robot)
        trajectories.spiral!(move_ifnomarker!)
    end
end

# ------- Исполняемая часть файла

using HorizonSideRobots
using .FindMarker
robot = Robot("9/example_9.3.sit"; animate=true)
FindMarker.find_marker!(robot)
