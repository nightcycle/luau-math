--!strict
export type Point = Vector3
export type Vertex = Point
export type Normal = Vector3
export type Axis = Normal
export type Direction = Vector3
export type Line = { [number]: Vertex }
export type Surface = {
	Normal: Normal,
	Lines: { [number]: Line },
}
export type Radian = number
export type Degree = number
export type Face = string
export type Roundable = number | Vector2 | Vector3 | Color3 | CFrame
export type Alpha = number
export type Integer = number
export type Float = number
export type Double = number

return {}
