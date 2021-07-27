inverse(sides::Vector) = sides .|> inverse

inverse(sides::Tuple) = sides |> collect .|> inverse |> Tuple

left(sides::Vector) = sides .|> left

left(sides::Tuple) = sides |> collect .|> left |> Tuple

right(sides::Vector) = sides .|> right

right(sides::Tuple) = sides |> collect .|> right |> Tuple