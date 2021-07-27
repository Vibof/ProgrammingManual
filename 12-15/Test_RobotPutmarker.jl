module Test_RobotPutmarker
    using HorizonSideRobots
    include("horizonside.jl")
    include("robot_types.jl")
    #include("RobotsTypes.jl")
    #using .RobotTypes
    
    struct RobotPutmarker <: AbstractRobot  # - это просто тип-обертка, чтобы для этого типа можно было переопределить функцию move!
        robot::Robot
    end

    HorizonSideRobots.move!(robot::RobotPutmarker,side::HorizonSide) = begin 
        move!(robot.robot,side)
        putmarker!(robot.robot)
    end

    #=
    robot = Robot("labirint.sit"; animate = true)
    gran_robot = GranRobot{RobotPutmarker}(RobotPutmarker(robot))
    =#
    gran_robot = (Robot("labirint.sit"; animate = true) |> RobotPutmarker |> GranRobot{RobotPutmarker})

    around!(gran_robot)
end