"""
Модуль  FindMarker 
предназначени для решения задачи поиска маркера на неограниченном поле, содержащем прямолинейные полубесконечные перегородки
или перегородки конечной длины  

экспортирует функцию
    find_marker!

"""
module FindMarker
    export find_marker!

    using HorizonSideRobots
    include("functional_robot.jl")
    include("horizonside.jl")
    
    robot = Robot("10/example_10.1.sit", animate=true)

    include("_example_10.1.jl")
end

# ------- Исполняемая часть файла

using .FindMarker

FindMarker.find_marker!()

#=
ВНИМАНИЕ!!!: если здесь не использовать префикс "FindMarker.", 
то при первом запуске файла все будет работать хорошо, но при последующих запусках, 
поскольку модуль FindMarker при этом будет импортироваться повторно, возникнут связанные с этим проблемы 
=#