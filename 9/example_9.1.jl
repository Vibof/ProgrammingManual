"""
Модуль содержит определение функции markers_counter!(), 
возвращающей число маркеров внутри простого лабирина, содержащего внотри себя изолированные 
пергородки прямоугольной формы.
Требуется, чтобы изначально Робот находился в левом нижнем углу лабиринта.
В исходное положение Робот не возвращается 
"""
module MarkersCounter
    export markers_counter!, set_situation!, show!

    include("RectangularBordersRobot.jl")
    using .RectangularBordersRobot

    using HorizonSideRobots

    function markers_counter!()
        # Робот - в юго-западном углу

        counter() = if ismarker() num_markers+=1 end # - замыкание переменной num_markers
        
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

MarkersCounter.set_situation!("9/example_9.1.sit")
MarkersCounter.markers_counter!() |> println
show!()