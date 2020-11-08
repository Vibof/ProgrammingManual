"""
Модуль TrajectoriesRobot расширяет интерфейс модуля MovementsRobot, экспортирующего функции:
    
    move!(side)
    isborder(side)::Bool
    putmarker!()
    ismarker()::Bool
    temperature()::Int
    show!()

    movements!(side)
    get_num_movements!(side)::Int
    movements!(action!::Function, side)
    get_num_movements!(action!::Function, side)::Int
    movements!(side, num_steps::Integer)
    movements!(action!::Function, side, num_steps::Integer)

следующими обобщенными функциями, обеспечивающими перемещения Робота по специальным траекториям:

    snake!(move_fold!::Function, fold_direct::HorizonSide, general_direct::HorizonSide)      - обеспечивает перемещение "змейкой" 
    labirint_snake!(move_fold!::Function, fold_direct::HorizonSide, general_direct::HorizonSide) - обеспечивает перемещение "змейкой" по простому лабиринту
    comb!(there_and_back!::Function, clove_direct::HorizonSide, general_direct::HorizonSide) - обеспечивает перемещение по "гребенке"
    spiral!(move_act!::Function)                                                             - обеспечивает перемещение по спирали

Наличие параметров функционального типа у этих функций обеспечивают возможность их использования для решения самых разных задач, а также
возможность перемешать Робота по соответствующим траекториям, как при отсутствии внутренних перегородок, так и при их налаичии
"""
module TrajectoriesRobot
    export snake!, labirint_snake!, comb!, spiral!,
    move!, isborder, putmarker!, ismarker, temperature, show!, movements!, get_num_movements!,
    set_situation!

    include("MovementsRobot.jl")
    using .MovementsRobot

    include("../8/horizonside.jl")
    include("_trajectories_robot.jl")
end # module TrajectoriesRobot