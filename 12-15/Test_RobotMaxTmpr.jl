module Test_RobotMaxTmpr
    using HorizonSideRobots
    include("horizonside.jl")
    include("robot_types.jl")
    #include("RobotsTypes.jl")
    #using .RobotTypes

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

    robot = Robot("labirint.sit"; animate = true)
    robot = RobotMaxTmpr(robot, temperature(robot))
    gran_robot =  GranRobot{RobotMaxTmpr}(robot)

    around!(gran_robot)
    println(robot.max_temperature)
end