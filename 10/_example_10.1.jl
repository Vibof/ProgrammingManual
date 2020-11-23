robot = interface_save_robot(robot)
rectangular_borders = interface_rectangular_borders(robot)
line = interface_line(rectangular_borders.move!)
trajectories = interface_trajectories(robot)

"""
find_marker!()

перемещает Робота, находящегося где-то на неограниченном поле без внутренних перегородок, в клетку с маркером        
"""
find_marker!() = trajectories.spiral!(move_ifnomarker!)


function move_ifnomarker!(side)::Bool
#=
Перемещает Робота в заданном направлении и возвращает true, если в клетке с Роботом нет маркера,
в противном случае Робот остается на месте и возвращается false
=#
    if robot.ismarker()
        return false
    end
    move_unlimited_line!(side)
    return true
end

function move_unlimited_line!(side)
    coordinate = 0 # - текущая координата Робота относительно начального положения
    num_steps = 1 # - текущее число шагов при поиске края перегородки
    orthogonal = right(side) # - текущее направление поиска края перегородки
    back_side = orthogonal # - первоначальное направление поиска края перегородки
    while robot.isborder(side) # поиск края полубесконечной прямолинейной перегородки
        line.movements!(orthogonal,num_steps)
        if orthogonal == back_side 
            coordinate += num_steps
        else
            coordinate -= num_steps
        end
        num_steps+=1
        orthogonal=inverse(orthogonal)
    end
    #УТВ: Робот - за краем перегородки
    robot.move!(side)
    if coordinate > 0
        back_side = inverse(back_side)
    else
        coordinate = -coordinate
    end
    line.movements!(back_side,coordinate)
    #УТВ: Робот - в соседней, по отношению к исходной, позиции с другой стороны от перегородки
end
