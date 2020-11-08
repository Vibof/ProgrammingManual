"""
Модуль MovementsRobot расширяет стандартный командный интерфес Робота, определенный в модуле FunctionalRobot:
    isborder(side), putmarker!(), ismarker(), temperature(), show!(), set_situation(sit_file)
новыми функциями:
    movements!(side)
    get_num_movements!(side)
    movements!(action!::Function, side)
    get_num_movements!(action!::Function, side)
    movements!(side, num_steps::Integer)
    movements!(action!::Function, side, num_steps::Integer)
причем move!(side) переопределена теперь так:
    move!(side) = if !isborder(side) FunctionalRobot.move!(side) end
"""
module MovementsRobot
    export move!, isborder, putmarker!, ismarker, temperature, show!, movements!, get_num_movements!,
    set_situation! 

    include("../8/FunctionalRobot.jl")
    using .FunctionalRobot
    include("_movements_robot.jl")
end
