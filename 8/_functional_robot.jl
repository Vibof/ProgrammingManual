# Этот код предназначен для вставки в модуль FunctionalRobot (файл FunctionalRobot.jl)

using HorizonSideRobots
ROBOT = Robot() 
# тут просто требуется задать какое-либо значение типа Robot;
# а потом, с помощью функции init, оно уже может быть переопределено требуемым образом 

"""
    init(sitfile::AbstractString)

-- транслирует (в соответствующий внутренний объект модуля) обстановку, содержащуюся в файле sitfile     
"""
init(sitfile::AbstractString) = sitedit!(ROBOT,sitfile) # - инициализирует глобальную переменную ROBOT зачением тип Robot

HorizonSideRobots.isborder(side) = isborder(ROBOT,side)
HorizonSideRobots.ismarker() = ismarker(ROBOT)
HorizonSideRobots.temperature() = temperature(ROBOT)

HorizonSideRobots.putmarker!() = putmarker!(ROBOT)
HorizonSideRobots.move!(side) = move!(ROBOT, side)

HorizonSideRobots.show!() = show!(ROBOT) 
#HorizonSideRobots.show() = show(ROBOT) - это все равно работать не будет, т.к. в Main имеется стандартная show()

#HorizonSideRobots.save(filename::AbstractString) = save(ROBOT, filename) # ??? ERROR: MethodError: no method matching save(::HorizonSideRobots.SituationDatas.SituationData, ::String)


"""
    movements!(move_act!::Function, move_condition::Function)

Заставляет Робота делать шаги с помощью функции move_act!() 
до тех пор, пока логическая функция move_condition() не вернет false
"""
movements!(move_act!::Function, move_condition::Function) = while move_condition() move_act!()end

"""
    movements!(move_act!::Function, num_steps::Integer)

Заставляет Робота делать шаги с помощью функции move_act!() ровно num_steps раз
"""
movements!(move_act!::Function, num_steps::Integer) =
for _ in 1:num_steps
    move_act!()
end

"""
    get_num_movements!(move_condition::Function, side)

Возвращает число сделанных Роботом шагов в направлении side до тех пор, пока move_condition()==true
-- move_condition() - логическая функция, определяющая заданное условие      
"""
function get_num_movements!(move_condition::Function, side)
    num_steps=0
    movements!(()->(move!(side); num_steps+=1), move_condition)
    return num_steps
end

#---------------------------

"""
    snake!(move_fold!::Function, fold_direct::HorizonSide, general_direct::HorizonSide)

Осуществляет проход Робота по рядам "змейкой" (в местах разворота возможны самоналожения траектории, и последняя складка может получиться полностью наложена на предыдущую)
-- move_fold!(::HorizonSide) - функция, перемещающая Робота по очередной "складке змейки", и возвращающая логическое значение:
если возвращает false, то  - это сигнал, чтобы движение "змейкой" было остановлено
-- fold_direct - направление перемещения по (самой первой) "складке" 
-- general_direct - направление перемещения от "складки" к "складке"
"""
function snake!(move_fold!::Function, fold_direct::HorizonSide, general_direct::HorizonSide)
    function to_next_fold!(general_direct)                            # - функция, перемещающая на следующую "складку", если это возможно
        prew_direct = fold_direct
        fold_direct = inverse(fold_direct) # - внешняя переменная
        while isborder(general_direct)
            if !isborder(fold_direct)
                move!(fold_direct)
            else
                return false # прохода в направлении general_direct нигде нет
            end
        end
        #УТВ: в направлении general_direct нет перегородки
        move!(general_direct)
        movements!(()->move!(prew_direct), ()->!isborder(prew_direct))
        return true
    end

    if move_fold!(fold_direct)==false return end 
    while to_next_fold!(general_direct)==true && move_fold!(fold_direct)==true end
end

inverse(side::HorizonSide) = HorizonSide(mod(Int(side)+2, 4))

"""
    comb!(there_and_back!::Function, clove_direct::HorizonSide, general_direct::HorizonSide)

-- Осуществляет проход Роботом по рядам "гребенкой"
-- there_and_back!(::HorizonSide) - функция, перемещающая Робота по очередному "зубчику гребёнки", от его начала до конца и обрантно, и 
возвращающая логическое значение: если возвращает false, то  - это сигнал, чтобы движение "гребенкой" было остановлено
-- clove_direct - направления, определяющие направление перемещения по самому первому "зубчику"
-- general_direct - направление перемещения от "зубчика" к "зубчику"
"""
function comb!(there_and_back!::Function, clove_direct::HorizonSide, general_direct::HorizonSide)
    function to_next_clove(general_direct)
        if !isborder(general_direct)
            move!(general_direct)
            return true
        else
            return false
        end
    end

    there_and_back!(clove_direct)
    while to_next_clove(general_direct) && there_and_back!(clove_direct) end
end

#------------------ 
"""
    spiral!(move_act!::Function)

Перемещает Робота по раскручивающейся в положительном направлении спирали (первый шаг - на север) до момента наступления 
некотрого события, определяемого функцией move_act!(::HorizonSide)
-- move_act!(::HorizonSide) - функция перемещающая Робота в заданном направлении на 1 шаг (и, возможно, делающая что-то еще), и
возвращая логическое значение: если возвращается false, то - это сигнал, чтобы движение "змейкой" было остановлено.
"""
function spiral!(move_act!::Function)
    function next_round!(side, max_num_steps::Integer)     
    # - на очереном витке увеличивает длину сегмента спирали
        if side in (Sud, Nord) 
            max_num_steps+=1 
        end 
    end
    
    function move_direct!(move_act!::Function, side, max_num_steps::Integer)
    # перемещает Робота в заданном направлении не более чем на max_num_steps шагов с помощью функции move_act!(side) 
        num_steps=0
        while (num_steps <= max_num_steps) 
            if move_act!(side) == false
                return false
            end
            num_steps+=1
        end         
        return true
    end

    side = Nord
    max_num_steps = 1
    
    while move_direct!(move_act!, side, max_num_steps) == true 
        max_num_steps = next_round!(side, max_num_steps) 
        side=left(side)
    end
end

left(side::HorisonSide) = HorizonSide(mod(side(Int)+1, 4))