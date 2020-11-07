#= 
Определенные в этом файле функции контекстно зависимы от интерфейса, являющегося частью командного интерфейса Робота:
    move!(::Any), isborder(::Any)
=#

"""
    movements!(side, num_steps::Integer)

Перемещает Робота в заданном направлениии на заданное число шагов
"""
movements!(side, num_steps::Integer) = 
for _ in 1:num_steps 
    move!(side) 
end

"""
    movements!(action!::Function, side, num_steps::Integer)

Перемещает Робота в заданном направлении на заданное количество шагов, выполняя после каждого шага функцию action!()
"""
movements!(action!::Function, side, num_steps::Integer) = 
for _ in 1:num_steps       
    move!(side)
    action!()
end

#--------------------------------

"""
    movements!(side)

Перемещает Робота в заданном направлении до упора
"""
movements!(side)=
while !isborder(side)
    move!(side)
end

"""
    movements!(action!::Function, side)

Перемещает Робота в заданном направлении до упора, и после каждого сделанного Роботом шага, выполняет action()
"""
movements!(action!::Function, side)=
while !isborder(side)
    move!(side)
    action!()
end

#-----------------------------------
"""
    get_num_movements!(side)

Возвращает число сделанных Роботом шагов в направлении side при перемещении до упора
"""
function get_num_movements!(side)
    num_steps=0
    while !isborder(side)
        move!(side)
        num_steps+=1
    end
    return num_steps
end

"""
    get_num_movements!(action!::Function, side)

Перемещает Робота в заданном направлении до упора, после каждого шага выполняя action!(), и возвращает число 
сделанных шагов      
"""
function get_num_movements!(action!::Function, side)
    num_steps=0
    while !isborder(side)
        move!(side)
        action!()
        num_steps+=1       
    end
    return num_steps
end
