--!strict

export type Point = Vector3

export type Vertex = Point

export type Direction = Vector3

export type Normal = Direction

export type Axis = Normal

export type Line = {[number]: Vertex}

export type Surface = {
	Normal: Normal,
	Lines: { [number]: Line },
}

export type Radian = number

export type Degree = number

export type Float = number

export type Alpha = Float

export type Integer = number

export type Double = number

return {}
