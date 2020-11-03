# Этот код предназначен для вставки в модуль FunctionalRobot (файл FunctionalRobot.jl)

using HorizonSideRobots
ROBOT = Robot() 
# тут просто требуется задать какое-либо значение типа Robot;
# а потом, с помощью функции set_situation, оно уже может быть переопределено требуемым образом 

"""
    set_situation!(sitfile::AbstractString)

-- транслирует (в соответствующий внутренний объект модуля) обстановку, содержащуюся в файле sitfile     
"""
set_situation!(sitfile::AbstractString) = sitedit!(ROBOT, sitfile) # - инициализирует глобальную переменную ROBOT зачением тип Robot

#=
Было бы удобно иметь еще и такой метод функции set_situation:

function set_situation(robot::Robot)
    save(robot, "temp.sit")
    init("temp.sit")

end

Тогда бы можно было использовать наш модуль FunctionalRobot и в привычном режиме анимации:
- сначала в REPL
    julia> robot=Robot(animate=true)
- потом вручную установить требуемую обстановку 
- потом
    julia> FunctionalRobot.init(robot)

Но для этого требуется сначала "починить" HorizonSideRobots.save 
(эта функция, как оказалось, сейчас не работает по недосмотру, но это скоро будет исправлено)
=#

#HorizonSideRobots.save(filename::AbstractString) = save(ROBOT, filename) 
#!!!! Обнаружилась ошибка в пакете HorizonSide Robot - не работает функция save:
# ??? ERROR: MethodError: no method matching save(::HorizonSideRobots.SituationDatas.SituationData, ::String)

HorizonSideRobots.isborder(side) = isborder(ROBOT,side)
HorizonSideRobots.ismarker() = ismarker(ROBOT)
HorizonSideRobots.temperature() = temperature(ROBOT)

HorizonSideRobots.putmarker!() = putmarker!(ROBOT)
HorizonSideRobots.move!(side) = move!(ROBOT, side)

HorizonSideRobots.show!() = show!(ROBOT) 
#HorizonSideRobots.show() = show(ROBOT) - это все равно работать не будет, т.к. в Main имеется стандартная show()
