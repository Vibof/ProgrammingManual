"""
interface_borders_area(robot, direct)

-- robot - именованный кортеж функций (интерфейс), включающий функции:
 move!(side) (перемещает Робота на 1 клетку в заданном направлении), isborder(side)

-- возвращает именованный кортеж функций (интерфейс), состоящий из 2х функций:
    move!(side), get_area() 

Функция get_area() возвращает значение площади прямоугольной перегородки, полученное при выполнении 
функции move!(side)

Описание функции move!:

ДАНО: в направлении direct от Робота перегородки нет
side - направление перемещения, перпендикулярное направлению direct

РЕЗУЛЬТАТ: в направлении direct от Робота ПОПРЕЖНЕМУ НЕТ перегородки, 
но Робот прошёл мимо очередной перегородки, если таковая имелась на его пути, 
а если таких перегородок не было, то он росто дошел до упора. 
При этом, если в направлении side имелась преграждающая путь перегородка, то Робот остался на месте.
Если Робот сделал шаг, то возвращено true, если остался на месте, то возвращено false

Во внешнюю (замыкаемую) переременную записывается при этом значение площади пройденной перегородки
(если пройденной пергородки не было - Робот просто дошел до упора, то в этой переменной будет 0)    
"""
function interface_borders_area(robot, direct)
    # robot = interface_save_robot(...) | interface_rectangular_borders(...) || ....

    size_direct = 0
    size_side = 0
    area = 0

    function move!(side)
        while !robot.isborder(direct)
            if robot.move!(side)==false # robot.move!(side)==true <=> перемещение состоялось (Робот не уперся во внешнюю рамку)
                area = 0 # ! нужно обнулить, т.к. не нулевое значение могло остаться после предыдущего вызова этой функции                 return false
                return false
            end
        end
        # УТВ: в направлении direct имеется перегородка
 
        while robot.isborder(direct)          
            robot.move!(side)
            size_side+=1
        end
        #УТВ: Робот - стоит за этой перегородкой

        robot.move!(direct)
        while robot.isborder(inverse(side))
            robot.move!(direct)       
            size_direct += 1
        end
        for _ in 1:size_direct+1
            robot.move!(inverse(direct))
        end
        # size_direct - определен, Робот - стоит за перегродкой в прежнем положении

        area = size_side*size_direct
        size_side, size_direct = 0, 0
        return true
    end
    
    return (move! = move!, get_area = ()-> area)
end 
