#Предварительно требуется:
#include("horizonside.jl")

"""
interface_protected_robot(robot)

Возвращает кортеж замыканий переменной robot, содержащий функции:
(
    move! = (side)->(isborder(robot,side) ? false : (move!(robot,side);true)),
    isborder = (side)->isborder(robot,side),
    putmarker! = ()->putmarker!(robot),
    ismarker = ()->ismarker(robot),
    temperature = ()->temperature(robot),
    show! = ()->show!(robot),
    set_situation! = (sitfile)->sitedit!(robot, sitfile)  
)   
"""
interface_protected_robot(robot) = (
    move! = (side)->(isborder(robot,side) ? false : (move!(robot,side);true)),
    isborder = (side)->isborder(robot,side),
    putmarker! = ()->putmarker!(robot),
    ismarker = ()->ismarker(robot),
    temperature = ()->temperature(robot),
    show! = ()->show!(robot),
    set_situation! = (sitfile)->sitedit!(robot, sitfile)
    # save = save(robot, setfile) ...
) #---------------------------------------------

"""
interface_line(move!::Function)

    Получает функцию move!(side)::Bool, выполняющую перемещение Робота в ближайшую доступную клетку в направлении side и возвращающую true, 
    если доступная клетка существует, и оставляющую Робота на месте и возвращающую false - в противном случае

возвращает кортеж функций:

    movements!(side) - перемещает Робота "до упора" в заданном направлении
    movements!(side, num_steps::Integer) - перемещает Робота в заданном направлении на заданное число шагов
    movements!(action!::Function, side) - перемещает Робота "до упора" в заданном направлении
    movements!(action!::Function, side, num_steps::Integer) - перемещает Робота в заданном направлении на заданное число шагов

    get_num_movements!(side) - перемещает Робота "до упора" в заданном направлении и возвращает число сделанных шагов
    get_num_movements!(action!::Function, side) - перемещает Робота "до упора" в заданном направлении и возвращает число сделанных шагов

    при этом в соответствующих случаях здесь после каждого шага выполняется action!()

"""
interface_line(move!::Function) = begin
    movements!(side) = while move!(side)==true end
    movements!(side, num_steps::Integer) = for _ in 1:num_steps move!(side) end
    movements!(action::Function, side) = while move!(side)==true action() end
    movements!(action!::Function, side, num_steps::Integer) = for _ in 1:num_steps move!(side); action!() end

    function get_num_movements!(side)
        num_steps=0
        while move!(side)==true
            num_steps+=1
        end
        return num_steps
    end

    function get_num_movements!(action::Function, side)
        num_steps=0
        while move!(side)==true
            action()
            num_steps+=1
        end
        return num_steps
    end

    return (movements! = movements!, get_num_movements! = get_num_movements!)
end # interface_line-----------------------------------------------

"""
interface_trajectories(robot)

-- robot - именованный кортеж, содержащий интерфейс Робота, включающий функции
    move!, isborder
-- Возвращает интерфейс, содержащий функции:

snake!(move_fold!::Function, fold_direct::HorizonSide, general_direct::HorizonSide)

    Осуществляет проход Робота по рядам "змейкой" (в местах разворота возможны самоналожения траектории, и последняя складка может получиться полностью наложена на предыдущую)
    -- move_fold!(::HorizonSide) - функция, перемещающая Робота по очередной "складке змейки", и возвращающая логическое значение:
    если возвращает false, то  - это сигнал, чтобы движение "змейкой" было остановлено
    -- fold_direct - направление перемещения по (самой первой) "складке" 
    -- general_direct - направление перемещения от "складки" к "складке"

labirint_snake!(move_fold!::Function, fold_direct::HorizonSide, general_direct::HorizonSide)

    Осуществляет проход Робота по рядам простого лабиринта "змейкой". 
    Под простым лабиринтом понимается лабиринт который пересекается горизонтальными пярмыми ровно два раза. 
    При этом в местах разворота возможны самоналожения траектории (последняя складка будет получиться полностью наложеннной на предыдущую),
    но функция move_fold! отвечает только за одноразовый проход по складке (самоналожения могут возникать только при попытках перемещения на новую склажку).
    -- move_fold!(::HorizonSide) - функция, перемещающая Робота по очередной "складке змейки", и, ВОЗМОЖНО, возвращающая логическое значение:
    если возвращает false, то  - это сигнал, чтобы движение "змейкой" было остановлено 
    (в принципе, move_fold!(...) может возвращать и любое другое значение, не обязательно типа Bool, например - nothing, 
    но тогда "змейка" будет пройдена до самого конца)
    -- fold_direct - направление перемещения по (самой первой) "складке" 
    -- general_direct - направление перемещения от "складки" к "складке"

comb!(there_and_back!::Function, clove_direct::HorizonSide, general_direct::HorizonSide)

    -- Осуществляет проход Роботом по рядам "гребенкой"
    -- there_and_back!(::HorizonSide) - функция, перемещающая Робота по очередному "зубчику гребёнки", от его начала до конца и обрантно, и 
    возвращающая логическое значение: если возвращает false, то  - это сигнал, чтобы движение "гребенкой" было остановлено
    -- clove_direct - направления, определяющие направление перемещения по самому первому "зубчику"
    -- general_direct - направление перемещения от "зубчика" к "зубчику"

spiral!(move_act!::Function)

    Перемещает Робота по раскручивающейся в положительном направлении спирали (первый шаг - на север) до момента наступления 
    некотрого события, определяемого функцией move_act!(::HorizonSide)
    -- move_act!(::HorizonSide)::Bool - функция перемещающая Робота в заданном направлении на 1 шаг (и, возможно, делающая что-то еще), и
    возвращая логическое значение: если возвращается false, то - это сигнал, чтобы движение "змейкой" было остановлено.
"""
interface_trajectories(robot) = begin

    function snake!(move_fold!::Function, fold_direct::HorizonSide, general_direct::HorizonSide)
        if move_fold!(fold_direct)==false return end        
        while !robot.isborder(general_direct)           
            robot.move!(general_direct) 
            fold_direct = inverse(fold_direct)
            if move_fold!(fold_direct)==false return end
        end
    end # function snake!

    function labirint_snake!(move_fold!::Function, fold_direct::HorizonSide, general_direct::HorizonSide)
        function to_next_fold!(general_direct)::Bool 
        # перемещающает Робота в начало следующей "складки", если это возможно
            prew_direct = fold_direct
            fold_direct = inverse(fold_direct) # - внешняя переменная     
            while robot.isborder(general_direct)
                if !robot.isborder(fold_direct)                     
                    robot.move!(fold_direct) #!!! 
                else return false # прохода в направлении general_direct нигде нет
                end
            end
            #УТВ: в направлении general_direct нет перегородки
            robot.move!(general_direct) #!!!
            while !robot.isborder(prew_direct) 
                robot.move!(prew_direct) #!!! 
            end
            return true
        end # function to_next_fold!

        if move_fold!(fold_direct)==false return end 
        while to_next_fold!(general_direct)==true 
            if move_fold!(fold_direct)==false return end
        end
    end # function labirint_snake!

    function spiral!(move_act!::Function)
        function next_round!(side, max_num_steps::Integer) # - на очереном витке увеличивает длину сегмента спирали
            if side in (Sud, Nord) max_num_steps+=1 end
            return max_num_steps 
        end

        function move_direct!(move_act!::Function, side, max_num_steps::Integer)
        # перемещает Робота в заданном направлении не более чем на max_num_steps шагов с помощью функции move_act!(side) 
            num_steps=0
            while (num_steps <= max_num_steps) 
                if move_act!(side) == false return false end
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
    end # function spiral!
    
    function comb!(there_and_back!::Function, clove_direct::HorizonSide, general_direct::HorizonSide)

        function to_next_clove(general_direct)
            if !robot.isborder(general_direct)
                robot.move!(general_direct)
                return true
            else 
                return false
            end
        end

        there_and_back!(clove_direct)
        while to_next_clove(general_direct) && there_and_back!(clove_direct) 
        end
    end # function comb!
    
    return (snake! = snake!, labirint_snake! = labirint_snake!, comb! = comb!, spiral! = spiral!)
end # interface_trajectories-------------------------------------------------------------------------


"""
interface_rectangular_borders(robot)

-- robot - функциональный интерфейс (именованный кортеж), вулючающий функции: isborder, move!

-- возвращает кортеж из функций
    move!(side)::Bool, выполняющую перемещение Робота в ближайшую доступную клетку в направлении side и возвращающую true, 
    если доступная клетка существует, и оставляющую Робота на месте и возвращающую false - в противном случае - выполняет
    (И, ВОЗМОЖНО, ДЕЛАЮЩУЮ ЧТО-ТО УЩЁ ) 

    movements!(side) - перемещает Робота "до упора" в заданном направлении
    movements!(side, num_steps::Integer) - перемещает Робота в заданном направлении на заданное число шагов
    movements!(action!::Function, side) - перемещает Робота "до упора" в заданном направлении
    movements!(action!::Function, side, num_steps::Integer) - перемещает Робота в заданном направлении на заданное число шагов

    get_num_movements!(side) - перемещает Робота "до упора" в заданном направлении и возвращает число сделанных шагов
    get_num_movements!(action!::Function, side) - перемещает Робота "до упора" в заданном направлении и возвращает число сделанных шагов
    
при этом в соответствующих случаях здесь после каждого шага выполняется action!()

Все функци, составляющие возвращаемый интерфейс, перемещают Робота прямолинейно, выполняя при этом обход всех встречающихся на пути 
внутренних прямоугольных перегородок.
"""
interface_rectangular_borders(robot) = begin
    line = interface_line(robot.move!)

    function move!(side)::Bool
    # Перемещает Робота на один шаг в заданном направлении с обходом прямоугольной перегородки, если она стоит на пути
        num_steps = 0
        while robot.isborder(side) && !robot.isborder(left(side))
            robot.move!(left(side)) #!!!
            num_steps+=1
        end
        #УТВ: Робот стоит за краем перегородки, которую пытался обойти в поперечном направлении, или в углу, если это была внешняя рамка 
        
        ansver=robot.move!(side)
        if num_steps==0 # Робот не выполнял попытки обхода (перегородки на его пути не было)
            return ansver # == true
        end
        while robot.isborder(right(side)) 
            if robot.isborder(side)
                ansver = false # Робот уперся в угол (перегородка не является прямоугольной!)
                while robot.isborder(right(side))
                    robot.move!(inverse(side))
                end
                #УТВ: Робот возвращен на уровень переднего фронта перегородки
                break
            end
            #УТВ: перегородка, возможно, является прямоугольной
            robot.move!(side)
        end
        #УТВ: Робот прошел сбоку от перегородки за её пределы
        line.movements!(right(side), num_steps)
        #УТВ: Робот возвращен на главную линию своего движения
        return ansver
    end

    return (move! = move!, interface_line(move!)...) # - этот интерфейс состоит из новой функции move! и всех функций интерфейса interface_line, посторенных на основе этой новой функции move!
end # interface_rectangular_borders -------------------------------------------