--!strict
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
export type Alpha = number
export type Integer = number
export type Float = number
export type Double = number

local function round(v: any, interval: number?): any
	interval = interval or 1
	assert(interval ~= nil)
	if typeof(v) == "number" then
		return math.round(v / interval) * interval
	elseif typeof(v) == "Vector2" then
		return Vector2.new(round(v.X, interval), round(v.Y, interval))
	elseif typeof(v) == "Vector3" then
		return Vector3.new(round(v.X, interval), round(v.Y, interval), round(v.Z, interval))
	elseif typeof(v) == "Color3" then
		return Color3.new(round(v.R, interval), round(v.G, interval), round(v.B, interval))
	elseif typeof(v) == "CFrame" then
		return CFrame.fromMatrix(
			round(v.Position, interval),
			round(v.XVector, interval),
			round(v.YVector, interval),
			round(v.ZVector, interval)
		)
	end
	return v
end

local Geometry = require(script:WaitForChild("Geometry"))
local Mesh = require(script:WaitForChild("Mesh"))
local Algebra = require(script:WaitForChild("Algebra"))
local Noise = require(script:WaitForChild("Noise"))
export type Vector = Algebra.Vector
export type Matrix = Algebra.Matrix
export type NoiseSolver = Noise.NoiseSolver
export type BezierSolver<T> = Algebra.BezierSolver<T>

return {
	abs = math.abs,
	acos = math.acos,
	asin = math.asin,
	atan = math.atan,
	atan2 = math.atan2,
	ceil = math.ceil,
	clamp = math.clamp,
	cos = math.cos,
	cosh = math.cosh,
	deg = math.deg,
	exp = math.exp,
	floor = math.floor,
	fmod = math.fmod,
	frexp = math.frexp,
	ldexp = math.ldexp,
	log = math.log,
	log10 = math.log10,
	max = math.max,
	min = math.min,
	modf = math.modf,
	noise = math.noise,
	pow = math.pow,
	rad = math.rad,
	random = math.random,
	randomseed = math.randomseed,
	sign = math.sign,
	sin = math.sin,
	sinh = math.sinh,
	sqrt = math.sqrt,
	tan = math.tan,
	tanh = math.tanh,
	huge = math.huge,
	pi = math.pi,
	round = round,
	Geometry = Geometry,
	Mesh = Mesh,
	Algebra = Algebra,
	Noise = Noise,
}
