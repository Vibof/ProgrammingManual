include("RobotTypes.jl")
using .RobotTypes

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

function mark_gran!(robot)
    robot_putmarker = RobotPutmarker(robot)
    gran_robot = GranRobot{RobotPutmarker}(robot_putmarker)
    around!(gran_robot)
end

function max_tmpr_gran(robot)
    robot_max_tmpr = RobotMaxTmpr(robot, temperature(robot))
    gran_robot = GranRobot{RobotMaxTmpr}(robot_max_tmpr)
    around!(gran_robot)
    return robot_max_tmpr.max_temperature
end

function sum_tmprs_gran(robot)
    gran_robot = GranRobot{Robot}(robot)
    sum_tmprs=0
    around!(gran_robot)do
        sum_tmprs += temperature(robot)
    end
    return sum_tmprs
end

#-==========================================ИСПОЛНЯЕМАЯ ЧАСТЬ ФАЙЛА========================================================

robot = Robot("labirint.sit"; animate = true)

#=

=#

#=

=#