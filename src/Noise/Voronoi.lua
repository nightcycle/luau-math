--!strict
local Vector = require(script.Parent.Parent:WaitForChild("Algebra"):WaitForChild("Vector"))
type Vector = Vector.Vector

local Matrix = require(script.Parent.Parent:WaitForChild("Algebra"):WaitForChild("Matrix"))
type Matrix = Matrix.Matrix

local Solver = require(script.Parent:WaitForChild("Solver"))
type NoiseSolver = Solver.NoiseSolver

local Voronoi = {}
Voronoi.__index = Voronoi

function Voronoi:Get(vec: Vector): number
	assert(#self.Points > 0, "No points")
	vec = self.translateVector(vec)

	local points = self.Points
	local closest: Vector
	local cDist: number = math.huge

	for i, point: Vector in ipairs(points) do
		local dist = (point - vec).Magnitude
		if not closest or dist < cDist then
			closest = point
			cDist = dist
		end
	end

	local base = self:_Rand(closest)
	return self:_Compile(vec, base)
end

function Voronoi:Clone(): NoiseSolver
	local obj = Voronoi.new()
	return self:_CopyConfiguration(obj)
end

function Voronoi.new(...): NoiseSolver
	local self = Solver.new(...)
	setmetatable(self, Voronoi)
	return self
end

setmetatable(Voronoi, Solver)

return Voronoi
