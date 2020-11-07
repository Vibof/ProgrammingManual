"""
Модуль MovementsRobot расширяет стандартный командный интерфес Робота:
    move!(side), isborder(side), putmarker!(), ismarker(), temperature(), show!(), set_situation(sit_file),
наследуемый от модуля FunctionalRobot, новыми функциями:
    movements!(side)
    get_num_movements!(side)
    movements!(action!::Function, side)
    get_num_movements!(action!::Function, side)
    movements!(side, num_steps::Integer)
    movements!(action!::Function, side, num_steps::Integer)
"""
module MovementsRobot

    export move!, isborder, putmarker!, ismarker, temperature, show!, movements!, get_num_movements!,
    set_situation! 

    include("FunctionalRobot.jl")
    using .FunctionalRobot
    # теперь функции из "_movements_robot.jl" в данном модуле будут определены в нужном контексте

    include("_movements_robot.jl")
end
