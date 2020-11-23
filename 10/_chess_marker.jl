interface_robot_chess(robot_decart) = 
    # robot_decart = interface_robot_decart(...)
    (
        isborder = robot_decart.isborder,
        putmarker! = () ->  if iseven(sum(robot_decart.coordinates()))
                                robot_decart.putmarker!()
                            end,
        move! =  robot_decart.move!,
    ) 

function chess_mark!(r::Robot)
    robot = interface_robot(r)
    decart = interface_decart((x=0,y=0))

    robot_decart = interface_robot_decart(robot, decart)
    robot_chess = interface_robot_chess(robot_decart)
    line = interface_line(robot_chess.move!)
    trajectories = interface_trajectories(robot_chess)

    trajectories.snake!(Ost, Nord) do side
        robot_chess.putmarker!()
        line.movements!(robot_chess.putmarker!, side) 
    end
end


