using HorizonSideRobots

mutable struct Decart
    coordinates::NamedTuple{(:x,:y),Tuple{Int,Int}}

    Decart(coordinates::NamedTuple{(:x,:y),Tuple{Int,Int}}) = new(coordinates)
end

function coordinates!(decart::Decart, side::HorizonSide)
    if side == Ost
        decart.coordinates.x+=1
    elseif side == West
        decart.coordinates.x-=1   
    elseif side == Nord
        decart.coordinates.y+=1
    else
        decart.coordinates.y-=1
    end

    return (x=decart.coordinates.x,y=decart.coordinates.y)
end
coordinates(decart::Decart) = decart.coordinates

#------------Тест:
decart = Decart((x=0,y=0))
coordinates(decart) |> println          #  (x=0,y=0)
coordinates!(decart, Nord) |> println   #  (x=0,y=1)

