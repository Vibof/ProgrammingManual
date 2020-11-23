interface_robot_decart(robot, decart) =
    # robot = inteface_save_robot(...)
    # decart = interface_decart(...)
    (
        move! =  
            side -> if robot.move!(side) == true
                        decart.coordinates!(side)
                        true
                    end,
        isborder = robot.isborder,
        putmarker! = robot.putmarker!,
        ismarker = robot.ismarker,
        temperature = robot.temperature,
        show! = robot.show!,
        set_situation! = robot.set_situation!,
        coordinates = decart.coordinates
    )
