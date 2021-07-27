movements!(robot, side) = 
    while !isborder(robot, side) 
        move!(robot, side)
    end

movements!(action::Function, robot, side) = 
    while !isborder(robot, side)
        move!(robot, side) 
        action() 
    end

#=
movements(action::Function, condition::Function) = 
    while condition()
        action() 
    end

movements(()->(move!(robot,side);putmarker!(robot)), ()->!isborder(robot,side))
=#

movements!(robot, side, num_steps::Integer) = 
    for _ in 1:num_steps 
        move!(robot, side) 
    end

movements!(action::Function, robot, side, num_steps::Integer) = 
    for _ in 1:num_steps 
        move!(robot, side)
        action() 
    end

function get_num_movements!(robot, side) #countmovements!(robot,side)
    num_steps=0
    while !isborder(robot, side)
        move!(robot, side)
        num_steps+=1
    end
    return num_steps
end


function get_num_movements!(action::Function, robot, side) #countmovements!(::Function,robot,side)
    num_steps=0
    while !isborder(robot, side)
        move!(robot, side)
        action()
        num_steps+=1
    end
    return num_steps
end
