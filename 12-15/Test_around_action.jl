module Test_around_action
    using HorizonSideRobots
    include("horizonside.jl")
    include("robot_types.jl")
    #include("RobotsTypes.jl")
    #using .RobotTypes

    gran_robot = (Robot("labirint.sit"; animate = true) |> GranRobot{Robot})
    sum_tmprs=0
    around!(gran_robot)do
        global sum_tmprs
        sum_tmprs += temperature(gran_robot)
    end

    sum_tmprs/num_steps(gran_robot) |> println
end
