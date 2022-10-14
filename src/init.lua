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
local Physics = require(script:WaitForChild("Physics"))

export type Vector = Algebra.Vector
export type Matrix = Algebra.Matrix
export type NoiseSolver = Noise.NoiseSolver
export type BezierSolver<T> = Algebra.BezierSolver<T>
export type Pathfinder<T> = Pathfind.Pathfinder<T>

export type Newton = Physics.Newton
export type MetersPerSecondSquared = Physics.MetersPerSecondSquared
export type LightYear = Physics.LightYear
export type LightMinute = Physics.LightMinute
export type LightSecond = Physics.LightSecond
export type AstronomicalUnit = Physics.AstronomicalUnit
export type League = Physics.League
export type Mile = Physics.Mile
export type Kilometer = Physics.Kilometer
export type Meter = Physics.Meter
export type Feet = Physics.Feet
export type Centimeter = Physics.Centimeter
export type Millimeter = Physics.Millimeter
export type Micrometer = Physics.Micrometer
export type Nanometer = Physics.Nanometer
export type Picometer = Physics.Picometer
export type Planck = Physics.Planck
export type Millenia = Physics.Millenia
export type Century = Physics.Century
export type Decade = Physics.Decade
export type Year = Physics.Year
export type Week = Physics.Week
export type Day = Physics.Day
export type Hour = Physics.Hour
export type Minute = Physics.Minute
export type Second = Physics.Second
export type Millisecond = Physics.Millisecond
export type Microsecond = Physics.Microsecond
export type Nanosecond = Physics.Nanosecond
export type Picosecond = Physics.Picosecond
export type Ounce = Physics.Ounce
export type Pound = Physics.Pound
export type Stone = Physics.Stone 
export type Ton = Physics.Ton
export type Kiloton = Physics.Kiloton
export type Megaton = Physics.Megaton
export type Gram = Physics.Gram
export type Kilogram = Physics.Kilogram
export type Milligram = Physics.Milligram
export type Tonne = Physics.Tonne
export type Kilotonne = Physics.Kilotonne
export type Megatonne = Physics.Megatonne
export type MetersPerSecond = Physics.MetersPerSecond
export type KilometersPerHour = Physics.KilometersPerHour
export type Knot = Physics.Knot
export type FeetPerSecond = Physics.FeetPerSecond
export type MilesPerHour = Physics.MilesPerHour
export type Fahrenheit = Physics.Fahrenheit
export type Celsius = Physics.Celsius
export type Kelvin = Physics.Kelvin
export type Joule = Physics.Joule
export type Kilojoule = Physics.Kilojoule
export type Megajoule = Physics.Megajoule
export type Calorie = Physics.Calorie
export type Kilocalorie = Physics.Kilocalorie
export type BritishThermalUnit = Physics.BritishThermalUnit
export type Gigajoule = Physics.Gigajoule
export type Kilowatt = Physics.Kilowatt
export type Watt = Physics.Watt
export type Megawatt = Physics.Megawatt
export type Gigawatt = Physics.Gigawatt
export type Horsepower = Physics.Horsepower
export type FootPoundsPerMinute = Physics.FootPoundsPerMinute
export type Megapascal = Physics.Megapascal
export type Kilopascal = Physics.Kilopascal
export type Pascal = Physics.Pascal
export type Atmosphere = Physics.Atmosphere
export type Bar = Physics.Bar
export type Millibar = Physics.Millibar
export type PoundsPerSquareInch = Physics.PoundsPerSquareInch
export type KilogramMetersPerSecond = Physics.KilogramMetersPerSecond
export type Ohm = Physics.Ohm
export type Volt = Physics.Volt
export type Amp = Physics.Amp
export type Liter = Physics.Liter
export type Milliliter = Physics.Milliliter
export type Kiloliter = Physics.Kiloliter
export type Cup = Physics.Cup
export type Pint = Physics.Pint
export type Quart = Physics.Quart
export type Gallon = Physics.Gallon
export type CubicFeet = Physics.CubicFeet
export type CubicInch = Physics.CubicInch
export type CubicMeter = Physics.CubicMeter
export type GramPerCubicCentimeter = Physics.GramPerCubicCentimeter
export type KilogramsPerCubicMeter = Physics.KilogramsPerCubicMeter
export type GramPerMilliliter = Physics.GramPerMilliliter
export type SquareMeter = Physics.SquareMeter
export type SquareCentimeter = Physics.SquareCentimeter
export type SquareMillimeter = Physics.SquareMillimeter
export type SquareFeet = Physics.SquareFeet
export type SquareInch = Physics.SquareInch
export type SquareYard = Physics.SquareYard
export type SquareKilometer = Physics.SquareKilometer
export type SquareMile = Physics.SquareMile
export type Acre = Physics.Acre
export type Hectare = Physics.Hectare
export type Mol = Physics.Mol
export type JoulesPerKelvin = Physics.JoulesPerKelvin

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
	Physics = Physics,
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

--- @function Pathfind
--- @within Math
--- @param nodeData {[Vector]: {[number]: Vector}}
--- @return (start: Vector, finish: Vector) -> {[number]: Vector}
--- Takes a node network defined as a dictionary of vectors as keys, set to connection lists, then returns a Pathfinder that can be used to generate a list of steps between the two points. Pathfinder caches previous solutions for speed. Works with native Roblox Vector2 and Vector3s as well.

Math.__index = Math

return Math