module Decart
    using HorizonSideRobots
#=
Предполагается, что в пространстве имен Main определена функция inverse, например, путем вставки из файла "roblib.jl"
=#
    export init, move!, get_coord

    X_COORD=0
    Y_COORD=0

    function init(x=0,y=0)
        global X_COORD, Y_COORD
        X_COORD=0
        Y_COORD=0
    end

    function move!(r,side)
        global X_COORD, Y_COORD
        if side==Nord
            Y_COORD+=1
        elseif side==Sud
            Y_COORD-=1
        elseif side==Ost
            X_COORD+=1
        else # side==West
            X_COORD-=1
        end
        HorizonSideRobots.move!(r,side)
    end

    det_coord()=( X_COORD, Y_COORD)
end # module


using .Decart


#=
Теперь модуль Decart, можно испоьзовать, например, так:

    Decart.init()
    r = Robot()
    Decart.move!(r,Nord)
    x,y = Decart.get_coord()
=#
 

function mark_chess(r::Robot,n::Int)
    #УТВ: Робот - в юго-западном углу
    Decart.init()
    side=Ost
    mark_row(r,side,n)
    while isborder(r,Nord)==false
        Decart.move!(r,Nord)
        side = inverse(side)
        mark_row(r,side,n)
    end
end

function mark_row(r::Robot,size::HorizonSide, n::Integer)       
    putmarker_chess!(r,n)
    while isborder!(r,side)==false
        Decart.move!(r,side)
        putmarker_chess!(r,n)
    end
end


function putmarker_chess!(r::Robot,n::Integer)
    x,y = Decart.get_coord()
    x = mod(x,2n)
    y = mod(y,2n)
    if (x in 0:n && y in 0:n)  || (x in n+1:2n && y in n+1:2n) 
        putmarker!(r)
    end
end
