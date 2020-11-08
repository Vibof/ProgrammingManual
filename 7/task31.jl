#=
    ЗАДАЧА 31. 
    Робот находится где-то внутри лабиринта, граница которого обладает следующим свойством: любая горизонтальная 
    прямая пересекает границу ровно 2 раза (а произвольная вертикальная прямая пересекает ее любое четное число раз).

    Требуется подсчитать число имеющихся на поле маркеров (функция должна это число возвращать) и 
    возвратить Робота в исходное положение.
=#

function get_num_markers_lab(robot)
    #УТВ: Робот - в произвольной клетке лабиринта

    num_steps, side_steps = move_to_start!(robot, (Sud,West))
    num_steps=reverse(num_steps)
    side_steps=reverse(side_steps)
    #УТВ: Робот - в юго-западном углу

    side = Ost
    num_markers = get_num_markers!(robot, side)
    #ИНВАРИАНТ: Робот - в "начале" ряда
    while is_move_posible!(robot, Nord, side) == true
        move!(robot, Nord)
        movements!(robot,side)
        side = inverse(side)
        num_markers += get_num_markers!(robot, side)
    end
    #УТВ: Маркеры посчитаны, Робот где-то у северной границы в углу

    move_to_start!(robot, (Sud,West))
    #УТВ: Робот - снова в юго-западном углу

    for (i,n) in enumerate(num_steps)
        movements!(robot, side_steps[i], n)
    end
    #УТВ: Робот - в исходном положении
    return num_markers
end

function get_num_markers!(robot, side)
#=
    ДАНО: Робот - в начале ряда, side - направление перемещения
    РЕЗУЛЬТАТ: Робот - в противоположном конце ряда и возвращено число маркеров, имеющихся в этом ряду
=#    
    nun_markers = ismarker(robot) ? 1 : 0
    while !isborder(robot,side)
        move!(robot,side)
        ismarker(robot) && num_markers += 1 # - это тоже самое, что и if ismarker(robot) num_markers += 1 end
    end
    return num_markers
end


function is_move_posible!(robot, move_side, find_side)
#=
    ДАНО: Робот - в одном из концов ряда 
        -- find_side - направление к противоположному концу ряда
        -- move_side - направление для перемещения в следующий ряда
    РЕЗУЛЬТАТ:
        Проверена возможность переместить Робота (но не перемещет его) в направлении move_side, 
        при необходимости выполнив смещение Робота в направлении find_side на некоторое количество шагов
        
        Если перемещение в направлении move_side возможно, то Робот остановится возле первого возможного прохода, 
        и тогда будет возвращено - true;
        в противном случае будет возвращено - false, и Робот окажется у противоположного конца ряда.
=#
    while isborder(robot, move_side)
        if !isborder(robot, find_side) 
            move!(robot, find_side)
        else
            return false
        end
    end
    return true
end


function move_to_start(robot, start_side::Tuple)
#=
    Перемещает Робота из произвольной клетки в угол, заданный кортежем из двух ортогональных направлений start_side,
    и возвращает два массива равной длины: 
    первый массив содержит числа сделанных шагов в направлениях, содержащихся во втором массиве, в естественном порядке 
=#
    num_steps = Int[]
    side_steps = HorizoSide[]
    while !isborder(robot,start_side[2]) || is_posible!(robot, start_side[1], inverse(start_side[2]), num_steps, side_steps) # <=> Робот - не в стартовом углу
        for i in 1:2
            push!(num_steps, get_num_movements!(robot,start_side[i]))
            push!(side_steps, start_side[i])
        end
    end
    return num_steps, side_steps
end


function is_move_posible!(robot, move_side, find_side, num_steps::Vector, side_steps::Vector)
#=
    ДАНО: Робот - в одном из концов ряда 
        -- find_side - направление к противоположному концу ряда
        -- move_side - направление для перемещения в следующий ряда
        -- num_steps, side_steps - внешние массивы, которые додны быть пополнены новыми элементами
    РЕЗУЛЬТАТ:
        Проверена возможность переместиться в направлении move_side, при необходимости сместившись
        в направлении find_side на некотое количество шагов
        Если перемещение возможно, то Робот остановится возле первого возможного прохода, и будет возвращено -  true
        В противном случае будет возвращено - false, и Робот окажется у противоположного конца ряда  

        При этом во внешние массивы num_steps, side_steps добавлены число сделанных при поиске прохода шагов и
        направление поиска, соответственно
=# 
    num=0
    while isborder(robot, move_side)
        if !isborder(robot, find_side) 
            num += 1
            move!(robot,find_side)
        else
            push!(num_steps, num)
            push!(side_steps, find_side)
            return false
        end
    end
    push!(num_steps, num)
    push!(side_steps, find_side)

    return true
end