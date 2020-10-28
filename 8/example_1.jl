#= Решение задачи 4 в функциональном стиле
    ДАНО: Робот - Робот - в произвольной клетке ограниченного прямоугольного поля

    РЕЗУЛЬТАТ: Робот - в исходном положении, и клетки поля промакированы так:
        нижний ряд - полностью,
        следующий - весь, за исключением одной последней клетки на Востоке,
        следующий - за исключением двух последних клеток на Востоке,
        и т.д.
=#

using HorizonSideRobots
include("FunctionalRobot.jl")
using .FunctionalRobot

function mark_trap!(num_steps::Integer)
    # Робот - в юго-западном углу
    snake!(Ost, Nord) do fold_direct
        (fold_direct==Ost) && putmarker!()
        putmarkers!(fold_direct, num_steps)
        (fold_direct==West) && (num_steps -= 2)
    end
end

putmarkers!(side, num_steps) = movements!(()->(move!(side);putmarker!()), num_steps)

#--------------- Исполняемая часть файла ----------------

#FunctionalRobot.init(имя_файла_с_обстановкой) - пока это не работает - для этого требуется внести изменения в пакет HorizonSideRobots
#УТВ: Робот - юго-западном углу (так получается при импортировании модуля FunctionalRobots, и пока изменить это мы не можем, см. выше)

num_steps = get_num_movements!(()->!isborder(Ost), Ost)
movements!(()->move!(West), ()->!isborder(West))
mark_trap!(num_steps)

# Еще, если начальное положение Робота было произвольным, требуется вернуть его в исходное положение
show!()
