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

#=
---------------------------------------------------------------------------------------------------------------------------
АБСТРАКТНЫЕ ТИПЫ:
---------------------------------------------------------------------------------------------------------------------------
=#
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

#=
---------------------------------------------------------------------------------------------------------------------------
ИМЕЮЩАЯСЯ ИЕРАРХИЯ АБСТРАКТНЫХ ТИПОВ:
Any
  |___AbstractRobot (функции: isborder, putmatker!, ismarker, temperature, show!)
                  |___AbstractRobotDecart (дополнительные и переопределенные функции: move!, coordinates)
---------------------------------------------------------------------------------------------------------------------------
=#

#--------------------------------------------------------------------------------------------------------------------------

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
#-----------------------------------------------------------------------------

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
