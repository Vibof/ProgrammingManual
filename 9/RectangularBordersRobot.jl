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

    -- унаследованные от модуля MovementsRobot (фактически от - FunctionalRobot):
        set_situation!(file_name)
        isborder(side) 
        putmarker!()
        ismarker()
        temperature() 
        show!()  
"""
module RectangularBordersRobot
    export move!, movements!, get_num_movements!, isborder, putmarker!, ismarker, temperature, show!, set_situation!
       
    include("MovementsRobot.jl")
    using .MovementsRobot

    include("_rectangular_borders_move.jl")
    # - здесь переопределена функция move!(::Any) из модуля FunctionalRobot

    include("_movements_robot.jl")
    # - здесь вставлены контекстно зависимые функции, которые теперь определены в сформированном выше контексте 
    
    """
        movements!(side)

    Перемещает Робота пока возможно сделать шаг в заданном направлении (пока Робот не упрется во внешнюю рамку)
    и после каждого шага Робота выполняет action() 
    (если Робот уприрается в прямугольную перегородку то величина одного шага может составить несколько клеток)
    """
    movements!(side) = 
    while move!(side)==true 
    end

    """
        movements!(action::Function, side)

    Перемещает Робота пока возможно сделать шаг в заданном направлении (пока Робот не упрется во внешнюю рамку)
    и после каждого шага Робота выполняет action() 
    (если Робот уприрается в прямугольную перегородку то величина одного шага может составить несколько клеток)
    """
    movements!(action::Function, side) = 
    while move!(side)==true
        action()
    end

    #----

    """
        get_num_movements!(side)

    Перемещает Робота пока возможно сделать шаг в заданном направлении (пока Робот не упрется во внешнюю рамку), 
    и возвращает число сделанных шагов 
    (если Робот уприрается в прямугольную перегородку то величина одного шага может составить несколько клеток)
    """
    function get_num_movements!(side)
        num_steps=0
        while move!(side)==true
            num_steps+=1
        end
        return num_steps
    end

    """
    get_num_movements!(side)

    Перемещает Робота пока возможно сделать шаг в заданном направлении (пока Робот не упрется во внешнюю рамку)
    и после каждого шага Робота выполняет action(), и возвращает число сделанных шагов 
    (если Робот уприрается в прямугольную перегородку то величина одного шага может составить несколько клеток)
    """
    function get_num_movements!(action::Function, side)
        num_steps=0
        while move!(side)==true
            action()
            num_steps+=1
        end
        return num_steps
    end

 end
