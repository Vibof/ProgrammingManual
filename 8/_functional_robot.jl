# Этот код предназначен для вставки в модуль FunctionalRobot (файл FunctionalRobot.jl)

using HorizonSideRobots
ROBOT = Robot() 
# тут просто требуется задать какое-либо значение типа Robot;
# а потом, с помощью функции init, оно уже может быть переопределено требуемым образом 

#= !!!!!!!!!!!!!!!!!
"""
    init(sitfile::AbstractString)

-- транслирует (в соответствующий внутренний объект модуля) обстановку, содержащуюся в файле sitfile     
"""
init(sitfile::AbstractString) = sitedit!(ROBOT,sitfile) # - инициализирует глобальную переменную ROBOT зачением тип Robot

К сожалению интерфейс Робота сейчас не содержит функцию sitedit(::Robor, ::AdstractString)
Поэтому пока модуль FunctionalRobot пока можно использоватьдля решения задач, в которых начальное положение Рообота - это юго-западный угол
Но в ближайшее время это ограничение будет исправлено, и тогда можно будет пользоваться функцией init
=#

HorizonSideRobots.isborder(side) = isborder(ROBOT,side)
HorizonSideRobots.ismarker() = ismarker(ROBOT)
HorizonSideRobots.temperature() = temperature(ROBOT)

HorizonSideRobots.putmarker!() = putmarker!(ROBOT)
HorizonSideRobots.move!(side) = move!(ROBOT,side)

HorizonSideRobots.show!() = show!(ROBOT) 
#HorizonSideRobots.show() = show(ROBOT) - это все равно работать не будет, т.к. в Main имеется стандартная show()

#HorizonSideRobots.save(filename::AbstractString) = save(ROBOT, filename) # ??? ERROR: MethodError: no method matching save(::HorizonSideRobots.SituationDatas.SituationData, ::String)


"""
    movements!(move!::Function, move_condition::Function)

Заставляет Робота делать шаги с помощью функции move (возможно кроме собственно шага, делающей что-то еще), не имеющей аргуменов,
до тех пор, пока логическая функция move_condition (тоже без аргументов) будет возвращать значение true
"""
movements!(move_act!::Function, move_condition::Function) =
while move_condition()
    move_act!()
end

"""
    movements!(move!::Function, num_steps::Integer)

Заставляет Робота делать шаги с помощью функции move (возможно кроме собственно шага, делающей что-то еще), не имеющей аргуменов,
ровно num_steps раз
"""
movements!(move_act!::Function, num_steps::Integer) =
for _ in 1:num_steps
    move_act!()
end


"""
    get_num_movements!(move_condition::Function, side)

-- возвращает число сделанных Роботом шагов в направлении side до тех пор, пока move_condition()==true     
"""
function get_num_movements!(move_condition::Function, side)
    num_steps=0
    movements!(()->(move!(side); num_steps+=1), move_condition)
    return num_steps
end

#---------------------------


"""
    snake!(move_fold!::Function, fold_direct, general_direct)

-- Осуществляет проход Роботом по рядам "змейкой"
-- Перемещение по каждой "складке змейк" осуществляется с помощью функции move_fold
-- fold_direct, general_direct - направления, определяющие направление перемещения по самой первой "складке" и направление перемещения от "складки" к "складке", соответственно
"""
function snake!(move_fold!::Function, fold_direct, general_direct)
    walk_rows!(
        ()->move_fold!(fold_direct), # - это функция, перемещающая Робота по "складке"

        ()->(                             # - это функция, перемещающая на следующую "складку", если возможно
            fold_direct = inverse(fold_direct);
            if !isborder(general_direct)
                move!(general_direct)
                return true
            else
                return false
            end
        )
    )
end

inverse(side::HorizonSide) = HorizonSide(mod(Int(side)+2, 4))


"""
    comb!(move_clove!::Function, fold_direct, general_direct)

-- Осуществляет проход Роботом по рядам "расческой"
-- Перемещение по каждому "зубчику расчески" от его начала до конца и обрантно осуществляется с помощью функции move_clove!
-- fold_direct, general_direct - направления, определяющие направление перемещения по самому первому "зубчику" и направление перемещения от "зубчика" к "зубчику", соответственно
"""
function comb!(move_clove!::Function, clove_direct, general_direct)
    walk_rows!(
        ()->move_clove!(clove_direct), # функция, перемещающая Робота по "по зубчику и обратно"

        ()->(
            if !isborder(general_direct)
                move(general_direct)
                return true
            else
                return false
            end
        ) # функция, перемещающая на следующий "зубчик", если возможно
    )
end


"""
    walk_rows!(move_row!::Function, nextrow_ifposible!::Function)

 -- перемещает Робота по "соседним" рядам
 -- move_row! - функция без аргументов, перемещающая Робота по одному ряду
 -- nextrow_ifposible! - логическая функция без аргументов, перемещающая Робота в следующий ряд, если это возможно
 (возвращает true, если перемщение состоялось, и false - в противном случае)
"""
function walk_rows!(move_row!::Function, nextrow_ifposible!::Function)
    move_row!()
    while nextrow_ifposible!()
        move_row!()
    end
end
