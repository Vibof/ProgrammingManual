using HorizonSideRobots
include("horizonside.jl")

#=
-------------------------------------------------------------------------------
АБСТРАКТНЫЕ ТИПЫ
-------------------------------------------------------------------------------
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

#--------------------------------------------------------------------------------------------------------------------------

abstract type AbstractOrtRobot <: AbstractRobot
    #robot::TypeRobot - наличие этих полей предполагается у всех производных типов  (интерфес типа TypeRobot должен включать интерфейс типа Robot)
    #ort::HorizonSide
end

forvard!(robot::AbstractOrtRobot) = move!(robot.robot, robot.ort)

function rotation!(robot::AbstractOrtRobot, rotation::Function)
# rotation = left | right | inverse - функции из "horizonside.jl"
    robot.ort = rotation(robot.ort)
end

HorizonSideRobots.isborder(robot::AbstractOrtRobot, rotation::Function) = isborder(robot.robot, rotation(robot.ort))
# rotation = lift | right | inverse - функции из "horizonside.jl"

HorizonSideRobots.isborder(robot::AbstractOrtRobot) = isborder(robot.robot, robot.ort)

ort(robot::AbstractOrtRobot) = robot.ort

#=
-------------------------------------------------------------------------------
ИЕРАРХИЯ АБСТРАКТНЫХ ТИПОВ:

Any
  |___AbstractRobot (функции: isborder, putmatker!, ismarker, temperature, show!)
                  |___AbstractRobotDecart (дополнительные и переопределенные функции: move!, coordinates)
                  |
                  |___AbstractOrtRobot (дополнительные и переопределенные функции: forvard!, isborder, rotation!)
--------------------------------------------------------------------------------------------------------------------------
КОНКРЕТНЫЕ ТИПЫ (в том числе - параметрические):
-------------------------------------------------------------------------------------------------------------------------
=#
mutable struct Decart
    coordinates::NamedTuple{(:x,:y),Tuple{Int,Int}}

    Decart(coordinates::NamedTuple{(:x,:y),Tuple{Int,Int}}) = new(coordinates)
end

function coordinates!(decart::Decart, side::HorizonSide)
    x = decart.coordinates.x
    y = decart.coordinates.y
    if side == Ost
        x+=1
    elseif side == West
        x-=1
    elseif side == Nord
        y+=1
    else
        y-=1
    end
    decart.coordinates = (;x,y); #(x=x,y=y)
end

coordinates(decart::Decart) = decart.coordinates

#--------------------------------------------------------------------------------------------------------------------------

struct RobotDecart{TypeRobot} <: AbstractRobotDecart
    robot::TypeRobot 
    decart::Decart 

    RobotDecart{TypeRobot}(robot, coords) where TypeRobot = new(robot, Decart(coords))
    RobotDecart{TypeRobot}(robot) where TypeRobot = RobotDecart(robot, (x=0, y=0))
end

#--------------------------------------------------------------------------------------------------------------------------

mutable struct OrtRobot{TypeRobot} <: AbstractOrtRobot
    robot::TypeRobot
    ort::HorizonSide

    OrtRobot{TypeRobot}(robot, ort) where TypeRobot = new(robot, ort)
    OrtRobot{TypeRobot}(robot) where TypeRobot = OrtRobot{TypeRobot}(robot, Nord)
end
#--------------------------------------------------------------------------------------------------------------------------

mutable struct GranRobot{TypeRobot}
    robot::OrtRobot{TypeRobot}

    decart::Decart
    num_steps::Int

    function GranRobot{TypeRobot}(robot::TypeRobot) where TypeRobot
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
        new(ort_robot, Decart((x=0,y=0)), 0) #, positive)
    end
end # struct GranRobot{TypeRobot}


function forvard!(robot::GranRobot)
    forvard!(robot.robot)
    coordinates!(robot.decart, ort(robot))
    
    if !isborder(robot.robot, left)
        rotation!(robot.robot, left)
    else
        while isborder(robot.robot)
            rotation!(robot.robot, right)
        end
    end
    #УТВ: Робот развернут так, чтобы следующий шаг вперед будет шагом вдоль границы в положительном направлении
    
    robot.num_steps += 1
end

coordinates(robot::GranRobot) = coordinates(robot.decart)

num_steps(robot::GranRobot) = robot.num_steps

ort(robot::GranRobot) = ort(robot.robot)

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

#-----------------------------------------------------------------------------------------------------------------
#=
ИЕРАРХИЯ ИЕРАРХИЯ АБСТРАКТНЫХ И КОНКРЕТНЫХ ТИПОВ ТИПОВ:

Any
  |___Decart (интерфейс: coordinates!, coordinates)
  |___AbstractRobot (интерфейс: isborder, putmatker!, ismarker, temperature, show!)
  |               |___AbstractRobotDecart (дополнительные функции: move!, coordinates)
  |               |
  |               |___RobotDecart{TypeRobot} - параметрический конкретный тип
  |               |
  |               |___AbstractOrtRobot (дополнительные/переопределенные функции: forvard!, isborder, rotation!)
  |                                  |
  |                                  |___OrtRobot{TypeRobot} - параметрический конкретный тип
  |
  |___GranRobot{TypeRobot} (forvard!, coordinates, num_steps, ort, around!)
=#
#-------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------
struct RobotPutmarker <: AbstractRobot
    robot::Robot
end
HorizonSideRobots.move!(robot::RobotPutmarker,side::HorizonSide) = begin 
    move!(robot.robot,side)
    putmarker!(robot.robot)
end

#-------------------------------------------------------------------------------------------------------------------------
mutable struct RobotMaxTmpr <: AbstractRobot
    robot::Robot
    max_temperature::Int
end
HorizonSideRobots.move!(robot::RobotMaxTmpr,side::HorizonSide) = begin 
    move!(robot.robot, side)
    t = temperature(robot.robot)
    if t > robot.max_temperature
        robot.max_temperature = t
    end 
end
#-------------------------------------------------------------------------------------------------------------------------
#-==========================================ИСПОЛНЯЕМАЯ ЧАСТЬ ФАЙЛА========================================================

robot = Robot("labirint.sit"; animate = true)
#=
robot_putmarker = RobotPutmarker(robot)
gran_robot = GranRobot{RobotPutmarker}(robot_putmarker)
around!(gran_robot)
=#
robot_max_tmpr = RobotMaxTmpr(robot, temperature(robot))
gran_robot = GranRobot{RobotMaxTmpr}(robot_max_tmpr)
around!(gran_robot)
robot_max_tmpr.max_temperature |> println