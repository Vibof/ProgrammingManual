"""
    move!(side)::Bool

Делает попытку переместить Робота на 1 шаг в заданном направлении, при необходимости выполняя обход 
изолированной прямоугольной перегородки, и возвращает значение true, если сделать шаг оказалось 
возможным, и false - в противном случае.

Если прямоугольная перегородка, которую должен обойти Робот, не вырождена в отрезок, то величина шага 
получится больше 1 клетки, и будет равна "толщине" этой перегoродки.

Если сделать шаг оказалось не возможно, т.е. если Робот упирается во внешнюю рамку, то он  остается на месте.
"""
function move!(side)::Bool
    condition() = !isborder(side) && isborder(left(side))
    num_steps = get_num_movements!(condition, side)
    #УТВ: Робот стоит за ререгородкой, которую пытался обойти, или в углу, если это была внешняя рамка 
    ansver = !isborder(left(side))
    if ansver==true
        step!() = MovementsRobot.move!(side) # тут без префикса "FunctionalRobot." был бы рекурсивный вызов 
        step!()
        condition() = isborder(right(side))        
        MoventsRobot.movements!(step!, condition)
        #УТВ: Робот обошел прямоугольную перегородку
    end
    MoventsRobot.movements!(right(side), num_steps)
    #УТВ: Робот возвращен на главную линию своего движения
    return ansver
end


