#= Решение задачи 4 в функциональном стиле
    ДАНО: Робот - Робот - в произвольной клетке ограниченного прямоугольного поля

    РЕЗУЛЬТАТ: Робот - в исходном положении, и клетки поля промакированы так:
        нижний ряд - полностью,
        следующий - весь, за исключением одной последней клетки на Востоке,
        следующий - за исключением двух последних клеток на Востоке,
        и т.д.
=#

module MarkTrapz

include("TrajectoriesRobot.jl")
using .TrajectoriesRobot
using HorizonSideRobots

#=
Расставляет маркеры в форме прямоугольной трапеции (или треугольника - как получится),
при условии, что изначально Робот находится в юго-западном углу
=#
function mark_trapz!(num_steps::Integer)

    function move_row!(fold_direct)::Bool
        (fold_direct==Ost) && putmarker!()
        putmarkers!(fold_direct, num_steps)
        (fold_direct==West) && (num_steps -= 2)
        return true       
    end
    snake!(move_row!, Ost, Nord) 
#=  Альтернативная запись с использование do-синтаксиса:
    snake!(Ost, Nord) do fold_direct
        (fold_direct==Ost) && putmarker!()
        putmarkers!(fold_direct, num_steps)
        (fold_direct==West) && (num_steps -= 2)
        return true
    end
end
=#
end

putmarkers!(side, num_steps) = movements!(putmarker!, side, num_steps)

function mark_trapz!()
    #УТВ: Робот - юго-западном углу
    num_steps = get_num_movements!(Ost)
    movements!(West)
    mark_trapz!(num_steps)
    #УТВ: маркеры расставлены требуемым образом

    # В общем случае тут должны быть действия по возвращению Робота в исходное положение
    show!()
end

end

#Исполняемая часть файла
using .MarkTrapz
MarkTrapz.mark_trapz!()

