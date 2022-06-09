--!strict
local Algebra = require(script.Parent.Parent:WaitForChild("Algebra"))

local Vector = require(script.Parent.Parent:WaitForChild("Algebra"):WaitForChild("Vector"))
type Vector = Vector.Vector

local Matrix = require(script.Parent.Parent:WaitForChild("Algebra"):WaitForChild("Matrix"))
type Matrix = Matrix.Matrix

local Solver = require(script.Parent:WaitForChild("Solver"))
type Solver = Solver.Solver

local Simplex = {}
Simplex.__index = Simplex

function Simplex:Get(vec: Vector): number
	vec = self.translateVector(vec)

	if vec.Size <= 3 then
		math.randomseed(self.Seed)
		local x = self.Frequency*(vec[1] or 0)
		local y = self.Frequency*(vec[2] or 0)
		local z = self.Frequency*(vec[3] or 0)
		return 0.5 + math.noise(x,y,z)*0.5
	end

	local sideLength: number = 1/self.Frequency
	local minPoint: Vector = (vec/sideLength):Floor()*sideLength
	local limit: Vector = Vector.one(vec.Size)*sideLength
	local points = {minPoint}

	for d=1, vec.Size do
		local unsortedValues = {}
		for fill=1, vec.Size do
			table.insert(unsortedValues, if fill <= d then 1 else 0)
		end

		-- get permutations
		local function permutate(list: {[number]: number}, size: number, n: number) --heap algorithm
			if #points == 2^vec.Size then return end
			if size == 1 then table.insert(points, minPoint + Vector.new(unpack(list))*limit) end
			for i=1, size do
				permutate(list, size-1, n)
				if size % 2 == 1 then
					local temp = list[1]
					list[1] = list[size]
					list[size] = temp
				else
					local temp = list[i]
					list[i] = list[size]
					list[size] = temp
				end
			end
		end
		permutate(unsortedValues, #unsortedValues, #unsortedValues)
	end
	local values = {}
	for i, p in ipairs(points) do
		values[i] = self:_Rand(p)
	end

	local function pairAndLerp(ps, vs)
		local pointPairs = {}

		local pointValueRegistry = {}

		for i, p in ipairs(ps) do
			pointValueRegistry[p] = vs[i]
		end

		for i=1, math.floor(#ps / 2) do
			pointPairs[ps[i]] = ps[i+#ps / 2]
		end

		local finalPointsList = {}
		local finalValues = {}

		for p1, p2 in pairs(pointPairs) do
			local v1 = pointValueRegistry[p1]
			local v2 = pointValueRegistry[p2]

			local a = (p1-vec).Magnitude
			local b = (p1-p2).Magnitude
			local c = (p2-vec).Magnitude

			local numerator = (a^2) + (b^2) - (c^2)
			local denominator = (2*a*b)
			local frac = numerator/denominator
			local angleS = math.acos(frac)
			if angleS ~= angleS then angleS = 0 end
		
			local adjDist: number =  math.min(math.cos(angleS)*(vec-p1).Magnitude, (p1-p2).Magnitude)

			local alpha = adjDist / b
			alpha = (alpha^2)*(3.0 - 2.0*alpha)
			local finalPoint = p1:Lerp(p2, alpha)
			local finalValue = Algebra.lerp(v1, v2, alpha)

			table.insert(finalPointsList, finalPoint)
			table.insert(finalValues, finalValue)
			-- end
		end

		if #finalPointsList <= 1 then
			return finalValues[1]
		else
			return pairAndLerp(finalPointsList, finalValues)
		end
	end

	local base = pairAndLerp(points, values)
	return self:_Compile(vec, base)
end

function Simplex:Clone(): Solver
	local obj = Simplex.new()
	return self:_CopyConfiguration(obj)
end

function Simplex.new(...)
	local self = Solver.new(...)
	setmetatable(self, Simplex)
	return self
end

setmetatable(Simplex, Solver)

return Simplex