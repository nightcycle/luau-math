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
export type Alpha = number
export type Integer = number
export type Float = number
export type Double = number
export type PerimeterSequence<T> = types.PerimeterSequence<T>

local Geometry = require(script:WaitForChild("Geometry"))
local Mesh = require(script:WaitForChild("Mesh"))
local Algebra = require(script:WaitForChild("Algebra"))
local Noise = require(script:WaitForChild("Noise"))
local Pathfind = require(script:WaitForChild("Pathfind"))

export type Vector = Algebra.Vector
export type Matrix = Algebra.Matrix
export type NoiseSolver = Noise.NoiseSolver
export type BezierSolver<T> = Algebra.BezierSolver<T>
export type Pathfinder<T> = Pathfind.Pathfinder<T>

--- @class Math
--- A basic utility for your everyday Roblox dev math needs. It also includes all native lua math functions. All types included in API are exported for easy reuse in a wider project.
local Math = {
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
	Geometry = Geometry,
	Mesh = Mesh,
	Algebra = Algebra,
	Noise = Noise,
	Pathfind = Pathfind,
}

type omniRound<T> = (v: T, interval: number?) -> T
type roundable = number | Vector2 | Vector3 | Color3 | CFrame
local roundIt: omniRound<roundable>
roundIt = function<T>(v: T, interval: number?): T
	interval = interval or 1
	assert(interval ~= nil)
	if typeof(v) == "number" then
		return math.round(v / interval) * interval :: any
	elseif typeof(v) == "Vector2" then
		local fX: roundable = roundIt(v.X, interval)
		assert(typeof(fX) == "number")
		local fY: roundable = roundIt(v.Y, interval)
		assert(typeof(fY) == "number")
		return Vector2.new(fX, fY) :: any
	elseif typeof(v) == "Vector3" then
		local fX: roundable = roundIt(v.X, interval)
		assert(typeof(fX) == "number")
		local fY: roundable = roundIt(v.X, interval)
		assert(typeof(fY) == "number")
		local fZ: roundable = roundIt(v.Z, interval)
		assert(typeof(fZ) == "number")
		return Vector3.new(fX, fY, fZ) :: any
	elseif typeof(v) == "Color3" then
		local fR: roundable = roundIt(v.R, interval)
		assert(typeof(fR) == "number")
		local fG: roundable = roundIt(v.G, interval)
		assert(typeof(fG) == "number")
		local fB: roundable = roundIt(v.B, interval)
		assert(typeof(fB) == "number")
		return Color3.new(fR, fG, fB) :: any
	elseif typeof(v) == "CFrame" then
		local pos: roundable = roundIt(v.Position, interval)
		assert(typeof(pos) == "Vector3")
		local xVec: roundable = roundIt(v.XVector, interval)
		assert(typeof(xVec) == "Vector3")
		local yVec: roundable = roundIt(v.YVector, interval)
		assert(typeof(yVec) == "Vector3")
		local zVec: roundable = roundIt(v.ZVector, interval)
		assert(typeof(zVec) == "Vector3")
		return CFrame.fromMatrix(pos, xVec, yVec, zVec) :: any
	end
	error("Bad variable")
	return v
end
--- Rounds the value to the nearest interval. For example 0.93567, at interval 0.05, would become 0.95
Math.round = roundIt

--- @prop Geometry Geometry
--- @within Math
--- Provides access to the geometry library

--- @prop Mesh Mesh
--- @within Math
--- Provides access to the mesh library

--- @prop Algebra Algebra
--- @within Math
--- Provides access to the algebra library

--- @prop Noise Noise
--- @within Math
--- Provides access to the noise library

--- @prop Pathfind Pathfind
--- @within Math
--- Provides access to the noise pathfinder

Math.__index = Math

return Math