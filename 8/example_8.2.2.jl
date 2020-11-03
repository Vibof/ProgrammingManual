include("FunctionalRobot.jl")
using .FunctionalRobot

include("TrajectoriesRobot.jl")
using .TrajectoriesRobot

function markers_counter!()
    # Робот - в юго-западном углу
    num_markers=ismarker() ? 1 : 0

    snake!(Ost, Nord) do side
        move!(side)
        if ismarker()
            num_markers+=1
        end
    end

    return num_markers
end

#--------------------------

markers_counter!() |> println