--!strict
local Vector = require(script.Parent.Parent:WaitForChild("Algebra"):WaitForChild("Vector"))
type Vector = Vector.Vector

local Matrix = require(script.Parent.Parent:WaitForChild("Algebra"):WaitForChild("Matrix"))
type Matrix = Matrix.Matrix

local Solver = require(script.Parent:WaitForChild("Solver"))
type NoiseSolver = Solver.NoiseSolver

local Cellular = {}
Cellular.__index = Cellular

function Cellular:Get(vec: Vector): number
	assert(#self.Points > 0, "No points")
	vec = self.translateVector(vec)

	local points = self.Points
	local closest: Vector
	local cDist: number = math.huge
	local farthest: Vector
	local fDist: number = 0

	for i, point: Vector in ipairs(points) do
		local dist = (point - vec).Magnitude
		if not closest or dist < cDist then
			closest = point
			cDist = dist
		end
		if not farthest or dist > fDist then
			farthest = point
			fDist = dist
		end
	end

	local base = cDist / self.SeparationLimit
	-- local base = math.abs(alpha-0.5)*2

	return self:_Compile(vec, base)
end

function Cellular:Clone(): NoiseSolver
	local obj = Cellular.new()
	return self:_CopyConfiguration(obj)
end

function Cellular.new(...): NoiseSolver
	local self = Solver.new(...)
	self.Points = {}
	setmetatable(self, Cellular)
	return self
end

setmetatable(Cellular, Solver)

return Cellular
