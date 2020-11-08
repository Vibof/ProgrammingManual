module MarkersCounter

include("TrajectoriesRobot.jl")
using .TrajectoriesRobot
using HorizonSideRobots

function markers_counter!()
    # Робот - в юго-западном углу

    counter() = if ismarker() num_markers+=1 end
    
    num_markers = 0
    labirint_snake!(Ost, Nord) do side
        counter()
        movements!(counter, side)
        return true
    end

    return num_markers
end

end
#-------------------------- Исполняемая часть файла

using .MarkersCounter

MarkersCounter.set_situation!("8/example_8.2.sit")
MarkersCounter.markers_counter!() |> println
MarkersCounter.show!()