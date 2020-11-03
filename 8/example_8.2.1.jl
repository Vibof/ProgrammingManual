include("MovementsRobot.jl")
using .MovementsRobot
 
include("TrajectoriesRobot.jl")
using .TrajectoriesRobot


# get_markers_counter() - функция высшего порядка, возвращающая интерфейс из 2х функций, обеспечивающих возможность подсчета числа маркеров на поле
function get_markers_counter()
    num_markers = ismarker() ? 1 : 0
    (()-> if ismarker() num_markers+=1 end, ()->num_markers)
end

#----------------- Исполняемая часть файла ------------------

markers_counter!, get_num = get_markers_counter()

# Функция counter_row!(side) перемещает Робота в конец ряда в заданном направлении и считает маркеры
counter_row!(side) = movements!(markers_counter!, side)

MovementsRobot.set_situation("example_8.2.sit")
#УТВ: Робот - в юго-западном углу простого лабиринта

snake!(count_row!, Ost, Nord)
#УТВ: Робот прошел "змейкой" все поле и находится у его северной границы
# При этом объект (который замыкают функции move_count!, get_num) содержит искомое число маркеров

get_num() |> println