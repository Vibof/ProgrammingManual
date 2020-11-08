"""
Модуль RectangularBordersRobot предназначен для использования в случае наличия на поле Роботом внутренних изолированных
перегородок прямоугольной формы (допускается вырождение прямоугольников в отрезки)

Интерфейс модуля RectangularBordersRobot содержит в себе интерфейсом модуля MovementsRobot 
и состоит из следующих функций.
    -- пререопределенные:   
        move!(side)::Bool 

        movements!(side, num_steps::Integer)
        movements!(action!::Function, side, num_steps::Integer)
        
        movements!(side)
        movements!(action!::Function, side)
        
        get_num_movements!(side)
        get_num_movements!(action!::Function, side)

    -- унаследованные от модуля TrajectotiesRobot:
        set_situation!(file_name)
        isborder(side) 
        putmarker!()
        ismarker()
        temperature() 
        show!()  

        snake!(move_fold!::Function, fold_direct::HorizonSide, general_direct::HorizonSide)      - обеспечивает перемещение "змейкой" 
        labirint_snake!(move_fold!::Function, fold_direct::HorizonSide, general_direct::HorizonSide) - обеспечивает перемещение "змейкой" по простому лабиринту
        comb!(there_and_back!::Function, clove_direct::HorizonSide, general_direct::HorizonSide) - обеспечивает перемещение по "гребенке"
        spiral!(move_act!::Function)                                                             - обеспечивает перемещение по спирали    

"""
module RectangularBordersRobot
    export move!, movements!, get_num_movements!, isborder, putmarker!, ismarker, temperature, show!, 
    set_situation!, snake!,labirint_snake!, comb!, spiral!
        
    include("_rectangular_borders_robot.jl")
    # - здесь переопределена функция move!(::Any) в контексте импортированного модуля MovementsRobot
 end
