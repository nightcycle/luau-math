--!strict

local Types = require(script.Parent.Types)

export type BezierSolver<T> = (alpha: Types.Alpha) -> T

local Vector = require(script:WaitForChild("Vector"))
export type Vector = Vector.Vector
local Matrix = require(script:WaitForChild("Matrix"))
export type Matrix = Matrix.Matrix

local Lerp = require(script.Lerp)
local Ease = require(script.Ease)

local Algebra = {
	lerp = Lerp,
	ease = Ease,
	bezier = function<T>(...): BezierSolver<T>
		local allPoints: { [number]: Vector3 | Vector2 } = { ... }
		local function solve(alpha: number, points: { [number]: Vector2 | Vector3 })
			local newPoints = {}
			for i = 1, #points - 1 do
				local a = points[i]
				local b = points[i + 1]
				table.insert(newPoints, Lerp(a, b, alpha))
			end
			if #newPoints <= 1 then
				return newPoints[1]
			else
				return solve(alpha, newPoints)
			end
		end

		return function(alpha)
			return solve(alpha, allPoints)
		end
	end,
	Vector = Vector,
	Matrix = Matrix,
}

return Algebra
