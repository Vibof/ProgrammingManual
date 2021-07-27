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

#---------------------------------------------------------------------------------------
struct TryRobot{TypeRobot <: Union{Robot,AbstractRobot}} <: AbstractTryRobot
    robot::TypeRobot
end
#-----------------------------------------------------------------------------------------

struct RectangularBordersRobot{TypeRobot <: Union{Robot,AbstractRobot}} <: AbstractTryRobot
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

mutable struct SnakeRobot{TypeRobot <: Union{Robot, AbstractRobot}} <: AbstractRobot
    robot::TypeRobot
    fold_direct::HorizonSide
    genral_direct::HorizonSide
    is_begin_fold::Bool

    SnakeRobot{TypeRobot}(robot::TypeRobot, fold_direct, general_direct) where TypeRobot = new(robot,fold_direct, general_direct, true) 
end

is_begin_fold(snake::SnakeRobot) = snake.is_begin_fold

Base.iterate(snake::SnakeRobot) = begin
    return (snake, nothing)
end

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

struct RobotPath{TypeRobot<:Union{Robot,AbstractRobot}} <: AbstractRobot
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