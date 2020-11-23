#=
    ДАНО: Робот - в произвольной клетке ограниченного прямоугольного поля
   
    РЕЗУЛЬТАТ: Робот - в исходном положении, и все клетки поля промакированы

    num_hor = переместить робота до упора на юг и вернуть число шагов
    num_vert = переместить робота на запад и вернуть число шагов

    side = Ost
    маркировать ряд в направлении side до упора
    wile isborder(r,Nord)==false
        move!(r,Nord)
        side = inverse(side)
        маркировать ряд в направлении side до упора
    end

    переместить робота до упора на юг 
    переместить робота на запад 

    movemens!(r,Ost,num_hor)
    movemens!(r,Nord,num_vert)

=#


#include("roblib.jl")

function mark_all(r::Robot)
    nun_vert = get_num_steps_movements!(r,Sud)
    nun_hor = get_num_steps_movements!(r,West)
    #УТВ: Робот - в юго-западном углу

    side = Ost
    mark_row!(r,side)
    while isborder!(r,Nord)==false
        side=inverse(side)
        mark_row!(r,side)
    end
    #УТВ: Робот - у северной границы, в одном из углов

    movements!(r,Sud)
    movements!(r,West)
    #УТВ: Робот - в юго-западном углу

    movemens!(r,Ost,num_hor)
    movemens!(r,Nord,num_vert)
end



