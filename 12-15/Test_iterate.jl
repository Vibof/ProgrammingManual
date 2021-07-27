module Test_iterate
    using HorizonSideRobots
    include("horizonside.jl")
    include("robot_types.jl")
    #include("RobotsTypes.jl")
    #using .RobotTypes

    robot = Robot("labirint.sit", animate=true)

    around = GranRobot{Robot}(robot)
    for robot in around
        temperature(robot) |> println
    end
end