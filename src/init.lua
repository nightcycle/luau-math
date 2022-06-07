--!strict

local Math = {}
function Math:__index(k)
	if rawget(Math, k) then
		return rawget(Math, k)
	else
		return math[k]
	end
end

local types = require(script:WaitForChild("Types"))
export type Point = types.Point
export type Vertex = types.Vertex
export type Normal = types.Normal
export type Axis = types.Axis
export type Direction = types.Direction
export type Line = types.Line
export type Surface = types.Surface
export type Radian = types.Radian
export type Degree = types.Degree
export type Face = types.Face
export type Roundable = types.Roundable

function Math.round(v: Roundable, interval: number) : Roundable | nil
	interval = interval or 1
	local result: Roundable | nil
	if typeof(v) == "number" then
		result = math.round(v/interval)*interval
	elseif typeof(v) == "Vector2" then
		result = Vector2.new(
			Math.round(v.X, interval) :: number,
			Math.round(v.Y, interval) :: number
		)
	elseif typeof(v) == "Vector3" then
		result = Vector3.new(
			Math.round(v.X, interval) :: number,
			Math.round(v.Y, interval) :: number,
			Math.round(v.Z, interval) :: number
		)
	elseif typeof(v) == "Color3" then
		result = Color3.new(
			Math.round(v.R, interval) :: number,
			Math.round(v.G, interval) :: number,
			Math.round(v.B, interval) :: number
		)
	elseif typeof(v) == "CFrame" then
		result = CFrame.fromMatrix(
			Math.round(v.Position, interval) :: Vector3,
			Math.round(v.XVector, interval) :: Vector3,
			Math.round(v.YVector, interval) :: Vector3,
			Math.round(v.ZVector, interval) :: Vector3
		)
	end
	return result
end

Math.Geometry = require(script:WaitForChild("Geometry"))
Math.Mesh = require(script:WaitForChild("Mesh"))
Math.Algebra = require(script:WaitForChild("Algebra"))
Math.Noise = require(script:WaitForChild("Noise"))

return setmetatable({}, Math)