"""
ИЕРАРХИЯ ИЕРАРХИЯ АБСТРАКТНЫХ И КОНКРЕТНЫХ ТИПОВ ТИПОВ:

Any
  |___Decart (интерфейс: coordinates!, coordinates)
  |
  |___AbstractRobot (интерфейс: isborder, putmatker!, ismarker, temperature, show!)
                  |
                  |___AbstractRobotDecart (дополнительные функции: move!, coordinates)
                  |
                  |___RobotDecart{TypeRobot} - параметрический конкретный тип
                  |
                  |___OrtRobot{TypeRobot} (дополнительные/переопределенные функции: forvard!, isborder, rotation!) - параметрический конкретный тип
                  |
                  |___GranRobot{TypeRobot} (forvard!, isborder, coordinates, num_steps, num_rotatins, ort, around!) - параметрический конкретный тип

"""
module RobotTypes
    export AbstractRobot, AbstractRobotDecart, RobotDecart, OrtRobot, GranRobot, 
    move!, isborder, putmatker!, ismarker, temperature, show!, forvard!, rotation!, num_steps, num_rotations, ort, around!

    using HorizonSideRobots
    include("horizonside.jl")
    include("robot_types.jl")
end