--!strict

--- @type Point Vector3
--- @within Math
--- A point in 3d space

export type Point = Vector3

--- @type Vertex Point
--- @within Math
--- A point used to create a line or shape

export type Vertex = Point

--- @type Direction Vector3
--- @within Math
--- An offset in 3d space

export type Direction = Vector3

--- @type Normal Direction
--- @within Math
--- A normalized direction with a magnitude of 1

export type Normal = Direction

--- @type Axis Normal
--- @within Math
--- A normal with irrelevant polarity so that if you flip it nothing should break.

export type Axis = Normal

--- @type Line {[number]: Vertex}
--- @within Math
--- A line as represented by two vertices. Vertex does not matter.

export type Line = {[number]: Vertex}

--- @type Surface {Normal: Normal, Lines: {[number]: Line}}
--- @within Math
--- A surface defined by both its normal as well as the lines which compose it.

export type Surface = {
	Normal: Normal,
	Lines: { [number]: Line },
}

--- @type PerimeterSequence {[number]: Vector2 | Vector3}
--- @within Math
--- A string of vertices usually created for the purpose of solving a perimeter. The final point should be different from first point.

export type PerimeterSequence<V> = {[number]: V}

--- @type Radian number
--- @within Math
--- A measurement of rotation where 2 pi is equal to a full revolution

export type Radian = number

--- @type Degree number
--- @within Math
--- A measurement of rotation where 360 is equal to a full revolution

export type Degree = number

--- @type Float number
--- @within Math
--- A non-integer real number

export type Float = number

--- @type Alpha Float
--- @within Math
--- A number between 0 and 1

export type Alpha = Float

--- @type Integer number
--- @within Math
--- A number rounded to the nearest whole.

export type Integer = number

--- @type Double number
--- @within Math
--- A number rounded to the nearest hundredths place.

export type Double = number

return {}
