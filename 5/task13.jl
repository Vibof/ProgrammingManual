#=
Рассмотрим задачу 13:
    ДАНО: Робот - в произвольной клетке ограниченного прямоугольной рамкой поля без внутренних перегородок и маркеров.

    РЕЗУЛЬТАТ: Робот - в исходном положении в центре косого креста (в форме X) из маркеров.

Решение могло бы быть, например, таким.
=#


#=
 Если в эту функцию дополнительно передавать кортеж направлений, то, если не аннотировать тип этого дополнительного параметра, эта функция получилась бы обобщенной
=#
function mark_kross_x(r::Robot)
    for side in ((Nord,Ost),(Sud,Ost),(Sud,West),(Nord,West))
        putmarkers!(r,side)
        move_by_markers!(r,inverse(side))
    end
    putmarker!(r)
end

# Если не аннотировать тип параметра side, то эта функция стала бы обобщенной
putmarkers!(r::Robot, side::NTuple{2,HorizonSide}) = 
    while isborder(r,side)==false 
        move!(r,side) 
    end

# Этот метод функции isborder дает ее специализацию для типа NTuple{2,HorizonSide} по параметру side
isborder(r::Robot,side::NTuple{2,HorizonSide}) = (isborder(r,side[1]) || isborder(r,side[2]))

#Этот метод функции HorizonSideRobots.move! дает ее специализацию типа NTuple{2,HorizonSide} по параметру side
HorizonSideRobots.move!(r::Robot,side::NTuple{2,HorizonSide}) = for s in side move!(r,s) end

#=
 Если не аннотировать тип параметра side, то эта функция стала бы обобщенной (но специализация для типа HorizonSide сохранилась бы)
=#
move_by_markers!(r::Robot,side::NTuple{2,HorizonSide}) = while ismarker(r) move!(r,side) end

# Этот метод функции inverse дает ее специализацию для типа NTuple{2,HorizonSide} по параметру side
inverse(side::NTuple{2,HorizonSide}) = (inverse(side[1]), inverse(side[2]))


#-------------------------------------------
function mark_kross(r::Robot, sides)
    for side in sides
        putmarkers!(r,side)
        move_by_markers!(r,inverse(side))
    end
    putmarker!(r)
end

putmarkers!(r::Robot,side) = while isborder(r,side)==false move!(r,side) end
move_by_markers!(r::Robot,side) = while ismarker(r) move!(r,side) end
inverse(side::HorizonSide) = HorizonSide(mod(Int(side)+2, 4))
```

Если этот код, с определениями этих 4-х функций находится в отдельном файле, то тогда при решении задачи 13 мы могли бы его использовать без всяких изменений, воспользовавшись функцией `include`. Но при этом, уже в новом файле с решением задачи 13, нам пришлось бы дополнительно  дать еще следующие три определения, специализирующих нужным образом  соответствующие функции:
```julia
isborder(r::Robot,side::NTuple{2,HorizonSide}) = (isborder(r,side[1] || isborder(r,side[2]))
HorizonSideRobots.move!(r::Robot,side::NTuple{2,HorizonSide}) = for s in side move!(r,s) end
inverse(side::NTuple{2,HorizonSide}) = (inverse(side[1]),inverse(side[2]))
```
В результате ранее определенная (обобщенная) функция  mark_kross(r::Robot,sides) решала бы и задачу 13. 

Больше того, если бы потребовалось, например, расставить маркеры еще и в форме 8-конечного креста, то уже вообще ничего программировать бы не потребовалось, достаточно было бы просто вызвать функцию `mark_kross` с фактическим параметром в позиции side имеющем значение 8-элементного кортежа `(Nord,(Nord-Ost),Ost,(Sud,Ost),Sud,(Sud,West),West,(Nord,West))`. Заметим, что тип этого кортежа есть `Tuple`, а не NTuple, т.к. составляющие его элементы имеют разный тип.   

Можно было бы даже совсем отказатьса от аннотирования типа аргумента `side` (с мыслью о том, что вдруг года-нибудь понадобится понимать под side что-нибудь отличное от того, что мы понимаем сейчас; например, в принципе, в какой-то другой ситуации направление может задаваться и словами "лево", "право"):
```julia
isborder(r::Robot,side) = (isborder(r,side[1] || isborder(r,side[2]))
HorizonSideRobots.move!(r::Robot,side) = for s in side move!(r,s) end
inverse(side) = (inverse(side[1]),inverse(side[2]))
```
И это делало бы последние три функции тоже обобщенными (правда мы пока точно не знаем, когда потенциал такого обобщения сможет быть реализованным, но мы сделали так на всякий случай, а вдруг это пригодится).

Исходя из всего сказанного, можно предположить, что на всякий случай и от аннотации типа аргумента r в определениях наших обобщенных функций  лучше отказаться ([см. еще ниже](#принцип-аннотирования-тпов-аргуметов-функции)). 

В итоге получаем следующий обобщенный код (теперь уже и по аргументу r)

```julia
function mark_kross(r,sides)
    for side in sides
        putmarkers!(r,side)
        move_by_markers!(r,inverse(side))
    end
    putmarker!(r)
end

putmarkers!(r,side) = while isborder(r,side)==false move!(r,side) end
move_by_markers!(r,side) = while ismarker(r) move!(r,side) end
inverse(side::HorizonSide) = HorizonSide(mod(Int(side)+2, 4))
```

А при решении задачи 13 дополнительно к этому получим
```julia
isborder(r::Robot,side::NTuple{2,HorizonSide}) = (isborder(r,side[1] || isborder(r,side[2]))
HorizonSideRobots.move!(r::Robot,side::NTuple{2,HorizonSide}) = for s in side move!(r,s) end
inverse(side::NTuple{2,HorizonSide}) = (inverse(side[1]),inverse(side[2]))
```
ЗАМЕЧАНИЕ.
Может показаться, что отказ от аннотирования типов аргументов функций существенно снизит надежность программного кода из-за того, что теперь возможны ошибки, связанные с передачей фанкциям параметров не тех типов, которые требуются. Однако на практике это не так, ткого рода ошибки быстро обнаруатся, как только дело дойдет до выполения узкоспециализированных методов в "глубине" функции. Просто стек выводимых сообщений об ошибках будет теперь получаться несколько длиннее, но до истинных причин такого рода ошибок "докопаваться" все-равно будет не так уж и сложно.

Таким образом, в файл roblib.jl имеет смысл помещать определения функций в как можно более обобщенном виде, что расширит сферу их применимости.
