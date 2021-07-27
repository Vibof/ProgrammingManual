using HorizonSideRobots
include("horizonside.jl")
#-------------------------------------------------------------------------------------------------------------------------

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


#??? Чем же тогда этот тип отличатся от AbstractRobot
abstract type AbstractTypeRobot
    #robot::TypeRobot - у всех производных типов предполагается наличие поля некоторого типа, у которого имеется поле robot::TypeRobot (TypeRobot вклютает интефес Robot)
end

#HorizonSideRobots.move!(robot::AbstractRobot, side) = move!(robot.robot, side)
HorizonSideRobots.isborder(robot::AbstractTypeRobot, side) = HorizonSideRobots.isborder(robot.robot, side)
HorizonSideRobots.putmarker!(robot::AbstractTypeRobot) = HorizonSideRobots.putmarker!(robot.robot)
HorizonSideRobots.ismarker(robot::AbstractTypeRobot) = HorizonSideRobots.ismarker(robot.robot)
HorizonSideRobots.temperature(robot::AbstractTypeRobot) = HorizonSideRobots.temperature(robot.robot)
HorizonSideRobots.show!(robot::AbstractTypeRobot) = HorizonSideRobots.show!(robot.robot)

#--------------------------------------------------------------------------------------------------------------------------------
abstract type AbstractOrtTypeRobot <: AbstractTypeRobot
    #robot::TypeRobot - наличие этих полей пердполагается у всех производных типов
    #ort::HorizonSide
end

#forvard!(robot::AbstractOrtTypeRobot) = HorizonSideRobots.move!(robot.robot.robot, robot.ort)
forvard!(robot::AbstractOrtTypeRobot) = HorizonSideRobots.move!(robot.robot, robot.ort)

function rotation!(robot::AbstractOrtTypeRobot, rotation::Function)
# rotation = lift | right | inverse - функции из "horizonside.jl"
    robot.ort = rotation(robot.ort)
end

#isborder(robot::AbstractOrtTypeRobot, rotation::Function) = HorizonSideRobots.isborder(robot.robot.robot, rotation(robot.ort))
#isborder(robot::AbstractOrtTypeRobot) = HorizonSideRobots.isborder(robot.robot.robot, robot.ort)

HorizonSideRobots.isborder(robot::AbstractOrtTypeRobot, rotation::Function) = HorizonSideRobots.isborder(robot.robot, rotation(robot.ort))
# rotation = lift | right | inverse - функции из "horizonside.jl"

HorizonSideRobots.isborder(robot::AbstractOrtTypeRobot) = HorizonSideRobots.isborder(robot.robot, robot.ort)

ort(robot::AbstractOrtTypeRobot) = robot.ort

#--------------------------------------------------------------------------------------------------------------------------

include("horizonside.jl")

mutable struct OrtTypeRobot{TypeRobot <: Union{AbstractTypeRobot, Robot}} <: AbstractOrtTypeRobot
    robot::TypeRobot
    ort::HorizonSide

    OrtTypeRobot{TypeRobot}(robot, ort) where TypeRobot = new(robot, ort)
    OrtTypeRobot{TypeRobot}(robot) where TypeRobot = OrtTypeRobot{TypeRobot}(robot, Nord)
end

#--------------------------------------------------------------------------------------------------------

mutable struct GranTypeRobot{TypeRobot <: Union{AbstractTypeRobot, Robot}} <: AbstractOrtTypeRobot
    robot::TypeRobot
    ort::HorizonSide

    decart::Decart
    num_steps::Int

    function GranTypeRobot{TypeRobot}(robot::TypeRobot) where {TypeRobot <: Union{AbstractTypeRobot, Robot}}
        # Надо развернуть Робота так, чтобы слева была граница и можно было бы сделать шаг вперед
        # Если рядом с Роботом вообще нет перегородок, или, наоборот, он ограничен со всех 4-х сторон, то тогода - прерывание
        if isa(robot, Robot)
            ort_robot = OrtTypeRobot{Robot}(robot)
        else
            ort_robot = OrtTypeRobot{Robot}(robot.robot)
        end

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
        new(robot, ort(ort_robot), Decart((x=0,y=0)), 0) #, positive)
    end
end # struct GranTypeRobot


function move!(robot::GranTypeRobot)
    forvard!(robot)
    coordinates!(robot.decart, ort(robot))
print("*")
    if !isborder(robot, left)
        rotation!(robot, left)
    else
        while isborder(robot)
            rotation!(robot, right)
        end
    end
    #УТВ: Робот развернут так, чтобы следующий шаг вперед будет шагом вдоль границы
print("*")    
    robot.num_steps += 1
end

coordinates(robot::GranTypeRobot) = coordinates(robot.decart)
num_steps(robot::GranTypeRobot) = robot.num_steps


#------------------------------------------------------------------------------------------------------

function around(robot::GranTypeRobot{TypeRobot}) where {TypeRobot} # ??? <: AbstractDecartRobot}
# Заставляет Робота, находящегося возле границы лабиринта, совершить ее полный обход и остановиться в исходном положении
    start_ort = ort(robot)
    start_coords = coordinates(robot)
    
    move!(robot)
    while coordinates(robot) != start_coords || ort(robot) != start_ort     
        move!(robot)
    end
end

#----------------------------------------------------

struct RobotPutmarker <: AbstractTypeRobot
    robot::Robot
end
HorizonSideRobots.move!(robot::RobotPutmarker,side::HorizonSide) = begin 
    HorizonSideRobots.move!(robot.robot,side)
    HorizonSideRobots.putmarker!(robot.robot)
end
#-==========================================ИСПОЛНЯЕМАЯ ЧАСТЬ ФАЙЛА========================================================

robot = Robot(animate=true)
robot_putmarker = RobotPutmarker(robot)
gran_robot = GranTypeRobot{RobotPutmarker}(robot_putmarker)