"""
Модуль  FindMarker экспортирует функции
    find_marker!, show!, set_situation!

"""
module FindMarker
    export find_marker!, show!, set_situation!

    include("RectangularBordersRobot.jl")
    using .RectangularBordersRobot

    function move_action!(side)::Bool
        if ismarker()
            return false
        end
        move!(side)
        return true
    end

    """
    find_marker!()

    перемещает Робота, находящегося где-то на неораниченном поле без внутренних перегородок, в клетку с маркером        
    """
    find_marker!() = spiral!(move_action!)
end

# ------- Исполняемая часть файла

using .FindMarker
FindMarker.set_situation!("9/example_9.2.sit")
FindMarker.find_marker!()
FindMarker.show!()

#=
ВНИМАНИЕ!!!: если здесь не использовать префикс "FindMarker.", 
то при первом запуске файла все будет работать хорошо, но при последующих запусках, 
поскольку модуль FindMarker при этом будет импортироваться повторно, возникнут связанные с этим проблемы 
=#