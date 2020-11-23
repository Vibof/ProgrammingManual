using HorizonSideRobots

function interface_decart(coord::NamedTuple{(:x,:y),Tuple{Int,Int}})
    x = coord.x
    y = coord.y

    function coordinates!(side::HorizonSide)
        if side == Ost
            x+=1
        elseif side == West
            x-=1
        elseif side == Nord
            y+=1
        else
            y-=1
        end
        return (x=x,y=y)
    end

    coordinates() = (x=x,y=y)

    return (coordinates = coordinates, coordinates! = coordinates!)
end

#=
#------------Тест:

decart = interface_decart((x=0,y=0)) 
decart.coordinates() |> println       # (x=0,y=0)
decart.coordinates!(Nord) |> println  # (x=0,y=1)

=#