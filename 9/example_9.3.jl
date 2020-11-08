"""
Модуль  FindMarker экспортирует функции
    find_marker!, show!, set_situation!

"""
module FindMarker
    export find_marker!, show!, set_situation!

    include("TrajectoriesRobot.jl")
    using .TrajectoriesRobot

    include("../8/horizonside.jl")

    function move_action!(side)::Bool
        if ismarker()
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
        while isborder(side) # поиск края полубесконечной прямолинейной перегородки
            movements!(orthogonal,num_steps)
            if orthogonal == back_side 
                coordinate += num_steps
            else
                coordinate -= num_steps
            end
            num_steps+=1
            orthogonal=inverse(orthogonal)
        end
        #УТВ: Робот - за краем перегородки
        move!(side)
        if coordinate > 0
            back_side = inverse(back_side)
        else
            coordinate = -coordinate
        end
        movements!(back_side,coordinate)
        #УТВ: Робот - в соседней, по отношению к исходной, позиции с другой стороны от перегородки
    end

    """
    find_marker!()

    перемещает Робота, находящегося где-то на неограниченном поле без внутренних перегородок, в клетку с маркером        
    """
    find_marker!() = spiral!(move_action!)
end

# ------- Исполняемая часть файла

using .FindMarker
FindMarker.set_situation!("9/example_9.3.sit")
FindMarker.find_marker!()
FindMarker.show!()

#=
ВНИМАНИЕ!!!: если здесь не использовать префикс "FindMarker.", 
то при первом запуске файла все будет работать хорошо, но при последующих запусках, 
поскольку модуль FindMarker при этом будет импортироваться повторно, возникнут связанные с этим проблемы 
=#