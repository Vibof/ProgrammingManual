using HorizonSideRobots
include("FunctionalRobot.jl")
using .FunctionalRobot

# get_markers_counter() - функция высшего порядка, возвращающая интерфейс из 2х функций, обеспечивающих возможность подсчета числа маркеров на поле
function get_markers_counter()
    num_markers = ismarker() ? 1 : 0
    (# эта скобка открывает кортеж
        function(side) # - тут определена анонимная функция одного аргумента (side)
            move!(side)
            if ismarker()
                num_markers+=1
            end
        end, # тут запятая разделяет два элемента возвращаемого функцией move_count кортежа анонимных функций

        ()->num_markers
    )# эта скобка закрывает кортеж
end

#----------------- Исполняемая часть файла ------------------


#FunctionalRobot.init(имя_файла_с_обстановкой) - пока это не работает - для этого требуется внести изменения в пакет HorizonSideRobots
#УТВ: Робот - юго-западном углу (так получается при импортировании модуля FunctionalRobots, и пока изменить это мы не можем, см. выше)

move_count!, get_num = get_markers_counter()

count_row!(side) = movements!(()->move_count!(side), ()->!isborder(side))
# -- перемещает Робота в конец ряда в заданном направлении и считает маркеры (это определение еще одной функции)

#УТВ: Робот - в юго-западном углу поля
snake!(count_row!, Ost, Nord)
#УТВ: Робот прошел "змейкой" все поле и находится у его северной границы
#При этом объект (который замыкают функции move_count!, get_num) содержит искомое число маркеров

get_num() |> println