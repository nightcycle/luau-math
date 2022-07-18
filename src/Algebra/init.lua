--!strict

local Types = require(script.Parent.Types)
type Alpha = Types.Alpha

export type BezierSolver<T> = (alpha: Alpha) -> T

local Vector = require(script:WaitForChild("Vector"))
export type Vector = Vector.Vector
local Matrix = require(script:WaitForChild("Matrix"))
export type Matrix = Matrix.Matrix


--- @class Algebra


local Algebra = {}
Algebra.__index = Algebra

--- @prop Vector Vector 
--- @within Algebra
--- Access to the Vector class

Algebra.Vector = Vector :: Vector

--- @prop Matrix Matrix 
--- @within Algebra
--- Access to the Matrix class

Algebra.Matrix = Matrix :: Matrix




--- @function lerp
--- @within Algebra
--- @param a: any
--- @param b: any
--- @param alpha: Alpha
--- @return any
--- performs a linear interpolation on a wide set of Roblox types, as well as any custom object with a :Lerp method.

local Lerp = require(script.Lerp)
function Algebra.lerp<T>(a: T, b: T, alpha: Alpha): T
	return Lerp(a, b, alpha)
end

--- @function ease
--- @within Algebra
--- @param alpha: Alpha
--- @param easingStyle: Enum.EasingStyle
--- @param easingDirection: Enum.EasingDirection
--- @return Alpha
--- adjusts and alpha value similar to how [TweenService:GetValue](https://developer.roblox.com/en-us/api-reference/function/TweenService/GetValue).

local Ease = require(script.Ease)
function Algebra.ease(alpha: Alpha, easingStyle: Enum.EasingStyle, easingDirection: Enum.EasingDirection): Alpha	
	return Ease(alpha, easingStyle, easingDirection)
end

--- @function bezier
--- @within Algebra
--- @param ... Vector | Vector2 | Vector3
--- @return (Alpha) -> Vector | Vector2 | Vector3
--- takes points as parameters and returns a function that when provided an alpha will give the corresponding point on the bezier line constructed from those parameters.

type bezierable = Vector2 | Vector3 | Vector
function Algebra.bezier<bezierable>(...): BezierSolver<bezierable>
	local allPoints: { [number]: bezierable} = { ... }
	assert(#allPoints > 1, "not enough points")
	local function solve(alpha: number, points: { [number]: bezierable }): bezierable?
		local newPoints = {}
		local function typeLerp(a: bezierable, b: bezierable, alpha: number): bezierable?
			if typeof(a) == "Vector2" then
				return Lerp(a, b, alpha)
			elseif typeof(a) == "Vector3" then
				return Lerp(a, b, alpha)
			elseif typeof(a) == "table" and getmetatable(a) == Vector then
				return Lerp(a, b, alpha)
			end
			return nil
		end

		for i = 1, #points - 1 do
			local a: bezierable = points[i]
			local b: bezierable = points[i + 1]
			local result: bezierable? = typeLerp(a, b, alpha)
			if result ~= nil then
				table.insert(newPoints, result)
			end
		end
		if #newPoints <= 1 then
			return newPoints[1]
		else
			return solve(alpha, newPoints)
		end
	end

	return function(alpha: Alpha): bezierable
		assert(allPoints ~= nil)
		local result: bezierable? = solve(alpha, allPoints)
		assert(result ~= nil)
		return result
	end
end
return Algebra
