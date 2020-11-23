#=
Задача 14
    ДАНО: Робот находится в произвольной клетке ограниченного прямоугольного поля, на котром возможны внутренние перегородки прямоугольной формы (некоторые прямоугольники могут вырождаться в отрезки) и в некоторых клетках изначально могут находиться маркеры.
    
    РЕЗУЛЬТАТ: Робот — в исходном положении в центре прямого креста из маркеров, расставленных вплоть до внешней рамки (кроме этих маркеров на поле могут находиться и какие-то другие).

    # На поле возможны внутренние перегородки ПРЯМОУГОЛЬНОЙ формы (допускаются и вырожденные прпямоугольники, т.е. - отрезки)
=#    
function mark_kross(r)
    for side in (Nord, West, Sud, Ost)
        num_steps = putmarkers!(r,side)
        movements!(r,inverse(side), num_steps) # в Практика-4 эту функция не очень удачно было названа просто move! Новое предложенное имя подчеркивает, что шагов может быть много 
    end
end


"""
    putmarkers!(r::Robot,side::HorizonSide)

-- Перемещает Робота в заданном направлении до упора, и после каждого шага ставит маркер и возвращает число сделанных шагов
"""
function putmarkers!(r::Robot,side::HorizonSide)
    num_steps=0 
    while move_if_possible!(r, side) == true
        putmarker!(r)
        num_steps += 1
    end 
    return num_steps
end

#=
Если 
    move_if_possible!(r, side) = 
    if isborder(r,side)==false 
        move!(r,side) 
        return true
    else
        return false
    end

    movements!(r::Robot, side::HorizonSide, num_steps::Int) = for _ in 1:num_steps move!(r,side) 

то мы имеем просто решение задачи 1.

Но чтобы получить решение задачи 14 потребуется переопределить функциии move_is_posible и movements!(::Robor,::HorizonSide,::Int), 
так, чтобы они могли обходить все встречающиеся на пути изолированные внутренние перегородоки прямоугольной формы.
=#

# Перемещает робота в заданном направлении, если это возможно, и возвращает true,
# если перемещение состоялось; в противном случае - false.
function move_if_possible!(r::Robot, direct_side::HorizonSide)::Bool
    orthogonal_side = left(direct_side)
    reverse_side = inverse(orthogonal_side)
    num_steps=0
    while isborder(r,direct_side) == true
        if isborder(r, orthogonal_side) == false
            move!(r, orthogonal_side)
            num_steps += 1
        else
            break
        end
    end
    #УТВ: Робот или уперся в угол внешней рамки поля, или готов сделать шаг (или несколько) в направлении 
    # side

    if isborder(r,direct_side) == false
        move!(r,direct_side)
        while isborder(r,reverse_side) == true
            move!(r,direct_side)
        end
        result = true
    else
        result = false
    end
    for _ in 1:num_steps
        move!(r,reverse_side)
    end
    return result
end

# Делает заданное число шагов в заданном направлении, при необходимости обходя внутренние перегородки.
# При этом величина одного "шага" может быть больше 1 и равна "толщине" встретившейся прямоугольной 
# перегородки
movements!(r::Robot, side::HorizonSide, num_steps::Int) =
for _ in 1:num_steps
    move_if_possible!(r,side) # - в данном случае возможность обхода внутренней перегородки гарантирована
end


"""
inverse(side::HorizonSide)

-- возвращает сторону горизонта, противоположную заданной    
"""
inverse(side::HorizonSide) = HorizonSide(mod(Int(side)+2, 4))


"""
left(side::HorizonSide)

-- возвращает сторону горизонта, следующую после заданной (в положительном направлении вращения)
"""
left(side::HorizonSide) = HorizonSide(mod(Int(side)+1, 4))


"""
right(side::HorizonSide)

-- возвращает сторону горизонта, предшествующую заданной (в положительном направлении вращения)
"""
right(side::HorizonSide) = HorizonSide(mod(Int(side)-1, 4))
