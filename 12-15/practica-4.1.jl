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

abstract type AbstractRobot
    #robot::Robot - наличие этого поля предполагается у всех производных типов
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
!!! Но если сделать так:

HorizonSideRobots.move!(robot::AbstractRobotDecart, side::HorizonSide) = begin
    move!(robot.robot, side)
    coordinates!(robot.decart, side)
end

то это приведёт к ошибке:

julia> robot = Robot(animate=true)
julia> robot_decart = RobotDecart(robot)
julia> move!(robot_decart, Nord)
ERROR: MethodError: no method matching move!(::Robot, ::HorizonSide)

ЭТА ПРОБЛЕМА БЫЛА ИЗ-ЗА ТОГО, ЧТО В ЭТОМ ФАЙЛЕ БЫЛИ ЕЩЁ ОПРЕДЕЛЕНИЯ ФУНКЦИИ move! ДЛЯ ДРУГИХ ТИПОВ, 
И В ЗАГОЛОВКАХ ЭТИХ ОПРЕДЕЛЕНИЙ ОТСУТСВОВАЛ ПРЕФИКС "HorizonSideRobots" 
Теперь это испарвлено.
=#

#--------------------------------------------------------------------------------------------------------------------------
struct RobotDecart <: AbstractRobotDecart
    robot::Robot 
    decart::Decart 

    RobotDecart(robot, coords) = new(robot, Decart(coords))
    RobotDecart(robot) = RobotDecart(robot, (x=0, y=0))
end
#=
HorizonSideRobots.isborder(robot::RobotDecart, side) = isborder(robot.robot, side)
HorizonSideRobots.putmarker!(robot::RobotDecart) = putmarker!(robot.robot)
HorizonSideRobots.ismarker(robot::RobotDecart) = ismarker(robot.robot)
HorizonSideRobots.temperature(robot::RobotDecart) = temperature(robot.robot)
HorizonSideRobots.show!(robot::RobotDecart) = show!(robot.robot)

move!(robot::RobotDecart, side::HorizonSide) = begin
    HorizonSideRobots.move!(robot.robot, side)
    coordinates!(robot.decart, side)
end

coordinates(robot::RobotDecart) = coordinates(robot.decart)
=#
#--------------------------------------------------------------------------------------------------------------------------


#=
!!! ТУТ БЫЛО НЕ ПРАВИЛЬНО:

mutable struct RobotDecartMarkersCounter <: AbstractRobotDecart
    robot::RobotDecart
    num_markers::Int
    RobotDecartMarkersCounter(robot, num_markers) = new(RobotDecart(robot), num_markers) #new(RobotDecart(robot), num_markers)
end

т.е. агрегировать объект типа RobotDecart - так можно былобы сделать, но тогда уже не нужно было наследовать от AbstractRobotDecart
- тут, так сказать, смешались два разных подхода к проектированию: агрегирование и наследование, но должно быть что-то одно! 

ПРАВИЛЬНО ТАК:
=#

mutable struct RobotDecartMarkersCounter <: AbstractRobotDecart
    robot::Robot
    decart::Decart
    num_markers::Int
    RobotDecartMarkersCounter(robot, num_markers) = new(robot, Decart((x=0,y=0)), num_markers) #new(RobotDecart(robot), num_markers)
end

function HorizonSideRobots.move!(robot::RobotDecartMarkersCounter, side::HorizonSide)
    move!(robot.robot, side)
    if ismarker(robot)
        robot.num_markers += 1
    end
    return nothing
end

num_markers(robot::RobotDecartMarkersCounter) = robot.num_markers
#------------------------------------------------------------------------------------------------------------------------

abstract type AbstractOrtRobot <: AbstractRobot
    #robot::Robot - наличие этих полей предполагается у всех производных типов
    #ort::HorizonSide
end

forvard!(robot::AbstractOrtRobot) = HorizonSideRobots.move!(robot.robot, robot.ort)

function rotation!(robot::AbstractOrtRobot, rotation::Function)
# rotation = left | right | inverse - функции из "horizonside.jl"
    robot.ort = rotation(robot.ort)
end

isborder(robot::AbstractOrtRobot, rotation::Function) = HorizonSideRobots.isborder(robot.robot, rotation(robot.ort))
# rotation = lift | right | inverse - функции из "horizonside.jl"

isborder(robot::AbstractOrtRobot) = HorizonSideRobots.isborder(robot.robot, robot.ort)

ort(robot::AbstractOrtRobot) = robot.ort

#--------------------------------------------------------------------------------------------------------------------------

mutable struct OrtRobot <: AbstractOrtRobot
    robot::Robot
    ort::HorizonSide

    OrtRobot(robot, ort) = new(robot, ort)
    OrtRobot(robot) = OrtRobot(robot, Nord)
end
#--------------------------------------------------------------------------------------------------------------------------

#=
!!! ТУТ БЫЛО НЕ ПРАВИЛЬНО:

mutable struct GranRobot <: AbstractOrtRobot
    robot::OrtRobot

    decart::Decart
    #num_steps::Int


    function GranRobot(robot::Robot)
        # Надо развернуть Робота так, чтобы слева была граница и можно было бы сделать шаг вперед
        # Если рядом с Роботом вообще нет перегородок, или, наоборот, он ограничен со всех 4-х сторон, то тогода - прерывание
        ............
        ............
        new(robot, Decart((x=0,y=0)))#, 0) #, positive)
    end
end # struct GranRobot

function HorizonSideRobots.move!(robot::GranRobot)
    forvard!(robot.robot) # -----------------------??? - эта функция должна былабы наследоваться!
    coordinates!(robot.decart, ort(robot.robot))
    
    if !isborder(robot.robot,left)# ---------------??? - эта функция должна былабы наследоваться!
        rotation!(robot.robot, left)# ----------- -??? - эта функция должна былабы наследоваться!
    else
        while isborder(robot.robot)# --------------??? - эта функция должна былабы наследоваться!
            rotation!(robot.robot, right)# --------??? - эта функция должна былабы наследоваться!
        end
    end
    #УТВ: Робот развернут так, чтобы следующий шаг вперед будет шагом вдоль границы
    # (если функция inverse(::GranRobot) ни разу не выполнялась, то Робот с самого начала повернут в нужную сторону)    
end

ort(robot::GranRobot) = ort(robot.robot) # --------??? - эта функция должна былабы наследоваться!

т.е. агрегировать объект типа OrtRobot - так можно былобы сделать, но тогда уже не нужно было наследовать от AbstractOrtRobot
- тут, так сказать, смешались два разных подхода к проектированию: агрегирование и наследование, но должно быть что-то одно! 

ПРАВИЛЬНО ТАК:
=#

mutable struct GranRobot <: AbstractOrtRobot
    robot::Robot
    ort::HorizonSide

    decart::Decart
    num_steps::Int

    function GranRobot(robot::Robot)
        # Надо развернуть Робота так, чтобы слева была граница и можно было бы сделать шаг вперед
        # Если рядом с Роботом вообще нет перегородок, или, наоборот, он ограничен со всех 4-х сторон, то тогода - прерывание
        ort_robot = OrtRobot(robot)
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
end # struct GranRobot


function HorizonSideRobots.move!(robot::GranRobot)
    forvard!(robot)
    coordinates!(robot.decart, ort(robot))
    
    if !isborder(robot, left)
        rotation!(robot, left)
    else
        while isborder(robot)
            rotation!(robot, right)
        end
    end
    #УТВ: Робот развернут так, чтобы следующий шаг вперед будет шагом вдоль границы в положительном направлении
    
    robot.num_steps += 1
end

coordinates(robot::GranRobot) = coordinates(robot.decart)
num_steps(robot::GranRobot) = robot.num_steps

#= 
Чтобы протестировать тип GranRobot нужно:

julia> include("имя данного файла") 

Теперь, прежде чем создать Робота-пограничника,
нужно в открывшемся окне с Роботом с помощью мыши создать границу (любой формы), перетащить Робота к этой границе
(так, чтобы эта граница проходила хотя бы с одной стороны от Робота)

После этого можно  уже вызывать конструктор (например, в REPL):

julia> robot_gran = GranRobot(robot)

(в результате Робот будет автоматически развернут относительно границы правильным образом)

А после этого можно командовать:

julia> move!(robot_gran)

в результате Робот будет перемещаться вдоль границы, какую бы сложную форму она не имела
=#
#--------------------------------------------------------------------------------------------------------------------------

function around!(robot::GranRobot)  # ??? <: AbstractDecartRobot}
# Заставляет Робота, находящегося возле границы лабиринта, совершить ее полный обход и остановиться в исходном положении
    start_ort = ort(robot)
    start_coords = coordinates(robot)
    
    move!(robot)
    while coordinates(robot) != start_coords || ort(robot) != start_ort
        move!(robot)
        #putmarker!(robot)
    end
end


#-==========================================ИСПОЛНЯЕМАЯ ЧАСТЬ ФАЙЛА========================================================

robot = Robot(animate=true)


