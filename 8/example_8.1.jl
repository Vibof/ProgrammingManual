#= Решение задачи 4 в функциональном стиле
    ДАНО: Робот - Робот - в произвольной клетке ограниченного прямоугольного поля

    РЕЗУЛЬТАТ: Робот - в исходном положении, и клетки поля промакированы так:
        нижний ряд - полностью,
        следующий - весь, за исключением одной последней клетки на Востоке,
        следующий - за исключением двух последних клеток на Востоке,
        и т.д.
=#

module MarkTrapz
    export mark_trapz!
    
    using HorizonSideRobots
    include("horizonside.jl")
    include("functional_robot.jl")
    

    function mark_trapz!(robot, num_steps::Integer)
    #=
    Расставляет маркеры в форме прямоугольной трапеции (или треугольника - как получится),
    при условии, что изначально Робот находится в юго-западном углу

    robot - интерфейс (именованный кортеж), содержащий функции: move!, isborder
    =#    
        line = interface_line(robot.move!)
        trajectories = interface_trajectories(robot)

        putmarkers!(side, num_steps) = line.movements!(robot.putmarker!, side, num_steps)
        
        trajectories.snake!(Ost, Nord) do fold_direct
            (fold_direct==Ost) && robot.putmarker!()
            putmarkers!(fold_direct, num_steps)
            (fold_direct==West) && (num_steps -= 2)
            return true
        end
    end

    function mark_trapz!(robot)
        #УТВ: Робот - юго-западном углу  
        robot = interface_protected_robot(robot)
        line = interface_line(robot.move!)
      
        num_steps = line.get_num_movements!(Ost)
        line.movements!(West)
        mark_trapz!(robot, num_steps)
        #УТВ: маркеры расставлены требуемым образом
    end

end # module

#---------------------Исполняемая часть файла

using HorizonSideRobots
using .MarkTrapz

robot = Robot(animate=true)
MarkTrapz.mark_trapz!(robot)



#=
ВНИМАНИЕ!!!: если здесь не использовать префикс "MarkTrapz.", 
то при первом запуске файла все будет работать хорошо, но при последующих запусках, 
поскольку модуль MarkTrapz при этом будет импортироваться повторно, возникнут связанные с этим проблемы 
=#