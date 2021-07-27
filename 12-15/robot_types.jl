"""
ИЕРАРХИЯ (ПОЛЬЗОВАТЕЛЬСКИХ) ТИПОВ:

Any
|___Decart (интерфейс: coordinates!, coordinates)
|
|___AbstractRobot (интерфейс: isborder, putmatker!, ismarker, temperature, show!)
    |
    |__AbstractTryRobot (дополнительные/переопределенные функции: move!, movments!, get_num_movements!)
    |   |
    |   |__TryRobot{TypeRobot}
    |   |
    |   |__RectangularBordersRobot{TypeRobot} (переопределенная функция: move!)
    |
    |__SnakeRobot{TypeRobot} (дополнительные/переопределенные функции: iterate, is_begin_fold) 
    |
    |__SpiralRobot{TypeRobot} (дополнительные/переопределенные функции: iterate)
    |
    |__RobotPath{TypeRobot} (дополнительные/переопределенные функции: move!, movements_to_back!)
    |
    |___OrtRobot{TypeRobot} (дополнительные/переопределенные функции: forvard!, isborder, rotation!)
    |
    |___AbstractRobotDecart (дополнительные/переопределенные функции: move!, coordinates)
        |
        |___RobotDecart{TypeRobot}
        |
        |___GranRobot{TypeRobot} (дополнительные/переопределенные функции: iterate, forvard!, num_steps, num_rotatins, ort)  
    
"""

#Вспомогательный тип:
mutable struct Decart
    coordinates::NamedTuple{(:x,:y), Tuple{Int,Int}}

    Decart(coordinates::NamedTuple{(:x,:y), Tuple{Int,Int}}) = new(coordinates)
end

function coordinates!(decart::Decart, side::HorizonSide)
    x = decart.coordinates.x
    y = decart.coordinates.y
    if side == Ost
        x += 1
    elseif side == West
        x -= 1
    elseif side == Nord
        y += 1
    else
        y -= 1
    end
    decart.coordinates = (;x,y); #(x=x,y=y)
end

coordinates(decart::Decart) = decart.coordinates

#------------------------------------АБСТРАКТНЫЕ ТИПЫ---------------------------------------------------------------------
abstract type AbstractRobot
    #robot::TypeRobot - наличие этого поля предполагается у всех производных типов (интерфес типа TypeRobot должен включать интерфейс типа Robot)
end

#HorizonSideRobots.move!(robot::AbstractRobot, side) = move!(robot.robot, side)
HorizonSideRobots.isborder(robot::AbstractRobot, side) = isborder(robot.robot, side)
HorizonSideRobots.putmarker!(robot::AbstractRobot) = putmarker!(robot.robot)
HorizonSideRobots.ismarker(robot::AbstractRobot) = ismarker(robot.robot)
HorizonSideRobots.temperature(robot::AbstractRobot) = temperature(robot.robot)
HorizonSideRobots.show!(robot::AbstractRobot) = show!(robot.robot)
#--------------------------------------------------------------------------------------------------------------------------

abstract type AbstractRobotDecart <: AbstractRobot
    #robot::Robot - наличие этих полей предполагается у всех производных типов
    #decart::Decart
end 

coordinates(robot::AbstractRobotDecart) = coordinates(robot.decart)

HorizonSideRobots.move!(robot::AbstractRobotDecart, side::HorizonSide) = begin
    move!(robot.robot, side) # - здесь требуется префикс "HorizonSideRobots." потому что в текущем пространстве
    coordinates!(robot.decart,side)
end
#-------------------------------------------------------------------------------------------------------------------------

abstract type AbstractTryRobot <: AbstractRobot
    #robot::TypeRobot
end

HorizonSideRobots.move!(robot::AbstractTryRobot, side) = 
    if isborder(robot, side)
        return false
    else
        move!(robot.robot, side)
        return true
    end

movements!(robot::AbstractTryRobot, side) = 
    while move!(robot, side)==true 
    end

movements!(robot::AbstractTryRobot, action::Function, side) = 
    while move!(robot, side)==true 
        action() 
    end

movements!(robot::AbstractTryRobot, side, num_steps::Integer) = 
    for _ in 1:num_steps 
        move!(robot, side) 
    end

function get_num_movements!(robot::AbstractTryRobot, side)
    num_steps=0
    while move!(robot, side)==true
        num_steps+=1
    end
    return num_steps
end
#-===========================================================================================================================

struct RobotDecart{TypeRobot} <: AbstractRobotDecart
    robot::TypeRobot 
    decart::Decart 

    RobotDecart{TypeRobot}(robot, coords) where TypeRobot = new(robot, Decart(coords))
    RobotDecart{TypeRobot}(robot) where TypeRobot = RobotDecart(robot, (x=0, y=0))
end

#--------------------------------------------------------------------------------------------------------------------------

mutable struct OrtRobot{TypeRobot} <: AbstractRobot
    robot::TypeRobot
    ort::HorizonSide

    OrtRobot{TypeRobot}(robot, ort) where TypeRobot = new(robot, ort)
    OrtRobot{TypeRobot}(robot) where TypeRobot = OrtRobot{TypeRobot}(robot, Nord)
end

forvard!(robot::OrtRobot) = move!(robot.robot, robot.ort)

function rotation!(robot::OrtRobot, rotation::Function)
# rotation = left | right | inverse - функции из "horizonside.jl"
    robot.ort = rotation(robot.ort)
end

HorizonSideRobots.isborder(robot::OrtRobot, rotation::Function) = isborder(robot.robot, rotation(robot.ort))
# rotation = left | right | inverse - функции из "horizonside.jl"

HorizonSideRobots.isborder(robot::OrtRobot) = isborder(robot.robot, robot.ort)

ort(robot::OrtRobot) = robot.ort

#--------------------------------------------------------------------------------------------------------------------------

mutable struct GranRobot{TypeRobot} <: AbstractRobotDecart
    robot::OrtRobot{TypeRobot}
    decart::Decart
    num_steps::Int
    num_rotations::Int

    GranRobot{TypeRobot}(robot::TypeRobot) where TypeRobot = GranRobot{TypeRobot}(robot, (x=0, y=0))

    function GranRobot{TypeRobot}(robot::TypeRobot, begin_coords) where TypeRobot
        # Надо развернуть Робота так, чтобы слева была граница и можно было бы сделать шаг вперед
        # Если рядом с Роботом вообще нет перегородок, или, наоборот, он ограничен со всех 4-х сторон, то тогода - прерывание
        ort_robot = OrtRobot{TypeRobot}(robot)
        n=0
        while !isborder(ort_robot)
            rotation!(ort_robot, left)
            n+=1
            if n > 3
                error("Рядом с Роботом нет перегородки ни с одной из сторон")
            end
        end
        #УТВ: Спереди от Робота перегородка
        n=0
        while isborder(ort_robot)
            rotation!(ort_robot, right)
            n+=1
            if n > 3
                error("Робот со всех сторон ограничен перегородками")
            end
        end
        #УТВ: слева от Робота - перегородка, спереди - свободно
        new(ort_robot, Decart((x=begin_coords.x,y=begin_coords.y)), 0, 0) #, positive)
    end
end # struct GranRobot{TypeRobot}


function forvard!(robot::GranRobot)
#Перемещает Робота вдоль границы в положительном направлении в соседнюю клетку 
#и добавляет число сделанных при этом поворотов, с учетом их знака, к значению robot.num_rotations 
    forvard!(robot.robot)
    coordinates!(robot.decart, ort(robot))
    if !isborder(robot.robot, left)
        rotation!(robot.robot, left)
        robot.num_rotations += 1
    else
        while isborder(robot.robot)
            rotation!(robot.robot, right)
            robot.num_rotations -= 1
        end
    end
    #УТВ: Робот развернут так, чтобы следующий шаг вперед будет шагом вдоль границы в положительном направлении
    
    robot.num_steps += 1
end

HorizonSideRobots.isborder(robot::GranRobot) = isborder(robot.robot)
HorizonSideRobots.isborder(robot::GranRobot, rotation::Function) = isborder(robot.robot, rotation)
num_steps(robot::GranRobot) = robot.num_steps
ort(robot::GranRobot) = ort(robot.robot)
num_rotations(robot::GranRobot) = robot.num_rotations

# Итератор для обхода границы:
Base.iterate(robot::GranRobot) = begin
    start_coordinates = coordinates(robot)
    start_ort = ort(robot)
    forvard!(robot)
    return robot, (start_coordinates, start_ort)
end 

Base.iterate(robot::GranRobot, state::Tuple) = begin    
    if state == (coordinates(robot), ort(robot))
        return nothing
    end
    forvard!(robot)
    return robot, state
end

#=
function around!(robot::GranRobot)
# Заставляет Робота, находящегося возле границы лабиринта, совершить ее полный обход и остановиться в исходном положении
    start_ort = ort(robot)
    start_coords = coordinates(robot)
    
    forvard!(robot)
    while coordinates(robot) != start_coords || ort(robot) != start_ort
        forvard!(robot)
        #putmarker!(robot)
    end
end

function around!(action::Function, robot::GranRobot)
# Заставляет Робота, находящегося возле границы лабиринта, совершить ее полный обход и остановиться в исходном положении,
# выполняя после каждого шага action()
    start_ort = ort(robot)
    start_coords = coordinates(robot)
        
    forvard!(robot)
    action()
    while coordinates(robot) != start_coords || ort(robot) != start_ort
        forvard!(robot)
        action()
    end
end
=#

#-=======================================================================

#---------------------------------------------------------------------------------------
struct TryRobot{TypeRobot} <: AbstractTryRobot
    robot::TypeRobot
end
#-----------------------------------------------------------------------------------------

struct RectangularBordersRobot{TypeRobot} <: AbstractTryRobot
    robot::TypeRobot
end

function HorizonSideRobots.move!(side)::Bool
# Перемещает Робота на один шаг в заданном направлении с обходом прямоугольной перегородки, если она стоит на пути
    num_steps = 0
    while isborder(robot, side) && !isborder(robot, left(side))
        move!(robot, left(side)) #!!!
        num_steps+=1
    end
    #УТВ: Робот стоит за краем перегородки, которую пытался обойти в поперечном направлении, или в углу, если это была внешняя рамка 

    ansver = move!(robot, side)
    if num_steps==0 # Робот не выполнял попытки обхода (перегородки на его пути не было)
         return ansver # == true
    end
    while isborder(robot, right(side))
        if isborder(robot, side)
            ansver = false # Робот уперся в угол (перегородка не является прямоугольной!)
            while isborder(robot, right(side))
                move!(robot, inverse(side))
            end
            #УТВ: Робот возвращен на уровень переднего фронта перегородки
            break
        end
        #УТВ: перегородка, возможно, является прямоугольной
        move!(robot, side)
    end
    #УТВ: Робот прошел сбоку от перегородки за её пределы
    try_robot = TryRobot(robot)
    movements!(try_robot, right(side), num_steps)
    #УТВ: Робот возвращен на главную линию своего движения
    return ansver
end

#------------------------------------------------------------------

mutable struct SnakeRobot{TypeRobot} <: AbstractRobot
    robot::TypeRobot
    fold_direct::HorizonSide # начальное направление движения по "складке змейки"
    genral_direct::HorizonSide # направление движения от "складки" к "складке"
    is_begin_fold::Bool # == true <=> Робот - находится в начале новой "складки"

    SnakeRobot{TypeRobot}(robot::TypeRobot, fold_direct, general_direct) where TypeRobot = new(robot,fold_direct, general_direct, true) 
end

is_begin_fold(snake::SnakeRobot) = snake.is_begin_fold

# Итератор, перемещающий Робота "змейкой" по полю, ограниченном прямоугольной рамкой
Base.iterate(snake::SnakeRobot) = (snake, nothing)

Base.iterate(snake::SnakeRobot, ::Any) = begin
    if isborder(snake, fold_direct) 
        if isborder(snake, general_direct)
            return nothing # змейка закончилась
        end
        move!(snake.robot, snake.general_direct)
        snake.fold_direct = inverse(snake.fold_direct)
        snake.is_begin_fold = true
    else
        move!(snake.robot, snake.fold_direct)
        snake.is_begin_fold = false
    end
    return snake, nothing
end
#-------------------------------------------------------------------------------

mutable struct SpiralRobot{TypeRobot} <: AbstractRobot
    robot::TypeRobot
    side::HorizonSide
    max_num_steps::Int
    num_steps::Int
    num_rotations::Int
    SpiralRobot{TypeRobot}(robot) where TypeRobot = new(robot,Nord,1,0,0)
end

# Итератор, перемещающий Робота по раскручивающейся (влево) спирали 
Base.iterate(::SpiralRobot) = begin
    move!(spiral.robot,spiral.side)
    spiral.num_steps += 1
    spiral.side = left(spiral.side) 
    spiral.num_rotations += 1
    return (spiral, nothing)
end

Base.iterate(::SpiralRobot, ::Any) = begin
    if spiral.num_steps == spiral.max_num_steps
        spiral.side = left(spiral.side)
        spiral.num_rotations += 1
    end
    move!(spiral.robot,spiral.side)
    if iseven(spiral.num_rotations)
        spiral.max_num_steps += 1
    end
    return (spiral, nothing)
end

#--------------------------------------------------------------------------

struct RobotPath{TypeRobot} <: AbstractRobot
    robot::TypeRobot
    path_sides::Vector{HorizonSide}
    path_num_steps::Vector{Int}
    RobotPath{TypeRobot}(robot) where TypeRobot = new(robot, HorizonSide[], Int[])
end
   
"""
    move!(robot, side)

-- перемещает Робота в заданном направлении в соседнюю клетку
"""
function HorizonSideRobots.move!(robot::RobotPath, side)
    if isempty(robot.path_sides) || robot.path_sides[end]!=side
        push!(robot.path_sides, side)
        push!(robot.path_num_steps, 1)
    else
        robot.path_num_steps[end] += 1
    end
    move!(robot.robot,side) # - то, что эта инструкция выполняется последней, - это может быть существенно, если функция move! возвращает значение (отличное от nothing), логическое, например    
end

"""
    movements_to_back!(robot)

-- возвращает Робота из конца своего маршрута в исходное положение
"""
movements_to_back!(robot) = 
    for (i,side) in enumerate(reverse(robot.path_sides)) 
        movements!(robot.robot, inverse(side), reverse(robot.path_num_steps)[i]) 
    end
#------------------------------------------------------------------------------------------