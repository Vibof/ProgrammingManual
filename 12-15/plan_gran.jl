using HorizonSideRobots
include("horizonside.jl")
include("horizonside_robot.jl")
include("robot_types.jl")

#include("RobotTypes.jl")
#using .RobotTypes


function data_plan_gran(robot::TypeRobot, coords=(x=0,y=0)) where TypeRobot
    gran_robot = GranRobot{TypeRobot}(robot, coords)
    pre_ort=ort(gran_robot) # - ориентация Робота на предыдущем шаге при движении вдоль границы

    xdata=Float64[]
    ydata=Float64[]

    for robot in gran_robot
        cur_ort = ort(robot)
        if cur_ort in (left(pre_ort), right(pre_ort)) # Робот совершил поворот на 90 град (находится в углу)
            x, y = coordinates(robot)
            if (pre_ort, cur_ort) in ((Sud,Ost),(Ost,Sud))
                dx, dy = 0.5, 0.5
            elseif (pre_ort, cur_ort) in ((Ost,Nord), (Nord,Ost))
                dx, dy = -0.5, 0.5
            elseif (pre_ort, cur_ort) in ((Nord,West), (West,Nord))
                dx, dy = -0.5, -0.5
            elseif (pre_ort, cur_ort) in ((Sud,West), (West,Sud))
                dx, dy = 0.5, -0.5
            else 
                error("Ошибка в выкладках!!!")
            end
            push!(xdata,x+dx)
            push!(ydata,y+dy)
            pre_ort=ort(robot)
        elseif cur_ort == inverse(pre_ort) # имел место РАЗВОРОТ (находится в "тупике")
            x, y = coordinates(robot)
            dx = dy = 0.5            
            if (pre_ort, cur_ort) == (Sud,Nord)
                push!(xdata,x+dx)
                push!(ydata,y-dy)
                push!(xdata,x-dx)
                push!(ydata,y-dy)                
            elseif (pre_ort, cur_ort) ==  (Ost,West)
                push!(xdata,x+dx)
                push!(ydata,y+dy)
                push!(xdata,x+dx)
                push!(ydata,y-dy)
            elseif (pre_ort, cur_ort) == (Nord,Sud)
                push!(xdata,x-dx)
                push!(ydata,y+dy)
                push!(xdata,x+dx)
                push!(ydata,y+dy)
            elseif (pre_ort, cur_ort) == (West,Ost)
                push!(xdata,x-dx)
                push!(ydata,y-dy)
                push!(xdata,x-dx)
                push!(ydata,y+dy)            
            else 
                error("Ошибка в выкладках!!!")
            end
            pre_ort=ort(robot)
        end

    end
    push!(xdata,xdata[1])
    push!(ydata,ydata[1])
    return xdata, ydata
end

function movements_to_ymin!(robot::TypeRobot) where TypeRobot
    gran_robot = GranRobot{TypeRobot}(robot)
    pre_ort=ort(gran_robot) # - ориентация Робота на предыдущем шаге при движении вдоль границы
    
    y_min = coordinates(gran_robot).y
    for robot in gran_robot
        y = coordinates(robot).y
        if y<y_min
            y_min=y
        end
    end

    for robot in gran_robot
        if coordinates(robot).y == y_min
            break
        end
    end

    return coordinates(gran_robot)
end


#-----------------------------------------------------------------------
using Plots
pyplot()

robot = Robot("labirint.sit")#, animate=true)

#УТВ: Робот - возле лабиринта
xdata, ydata = data_plan_gran(robot)
#УТВ: Робот - в исходном положении
plot(xdata,ydata; ratio = :equal, legend=false) |> display

robot_path=RobotPath{Robot}(robot)
end_coords=movements_to_ymin!(robot_path)
#УТВ: Робот - в самой нижней клетке возле лабиринта

dy = get_num_movements!(robot_path,Sud)
#УТВ: Робот - возле внешней рамки (на южной стороне)

xdata, ydata = data_plan_gran(robot_path, (x=end_coords.x, y=end_coords.y - dy))
plot!(xdata,ydata; ratio=:equal, legend=false) |> display

movements_to_back!(robot_path)
#УТВ: Робот - в исходном положении

show!(robot)
