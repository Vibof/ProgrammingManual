using HorizonSideRobots

"""
inverse(side::HorizonSide)

-- возвращает сторону горизонта, противоположную заданной    
"""
inverse(side::HorizonSide) = HorizonSide(mod(Int(side)+2, 4))


"""
left(side::HorizonSide)

-- возвращает сторону горизонта, следующую после заданной (в положительном направлении вращения)
"""
left(side::HorizonSide) = HorizonSide(mod(Int(side)+1, 4))


"""
right(side::HorizonSide)

-- возвращает сторону горизонта, предшествующую заданной (в положительном направлении вращения)
"""
right(side::HorizonSide) = HorizonSide(mod(Int(side)+1, 4))


"""
inverse(side::NTuple)

-- возвращает кортеж, содержащй стороны горизонта, противоположные заданным    
"""
inverse(side::NTuple) = Tuple(inverse.(collect(side)))


"""
inverse(side::AbstractVector)

-- возвращает вектор, сожержащий направления, противоположные заданным   
"""
inverse(side::AbstractVector) = inverse.(side)