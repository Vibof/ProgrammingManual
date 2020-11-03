"""
Модуль TrajectoriesRobot содержит определения обобщенных функций, обеспечивающих перемещения Робота по специальным траекториям:

    snake!(move_fold!::Function, fold_direct::HorizonSide, general_direct::HorizonSide) - обеспечивает перемещение "змейкой" 
    comb!(there_and_back!::Function, clove_direct::HorizonSide, general_direct::HorizonSide) - обеспечивает перемещение по "гребенке"
    spiral!(move_act!::Function) - обеспечивает перемещение по спирали

Наличие араметров функционального типа у этих функций обеспечивают возможность их использования для решения самых разных задач, а также
возможность перемешать Робота по соответствующим ттраектооиям как при отсутствии внутренних перегородок так и при их налаичии
"""
module TrajectoriesRobot
    export snake!, comb!, spiral!

    include("MovementsRobot.jl")
    using .FunctionalRobot

    include("horizonside.jl")
    include("_trajectories_robot.jl")
end # module TrajectoriesRobot