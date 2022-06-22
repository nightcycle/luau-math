--!strict
local Vector = require(script.Parent.Parent:WaitForChild("Algebra"):WaitForChild("Vector"))
type Vector = Vector.Vector

local Matrix = require(script.Parent.Parent:WaitForChild("Algebra"):WaitForChild("Matrix"))
type Matrix = Matrix.Matrix


local Solver = {}
Solver.__index = Solver

function Solver.translateVector(vec: Vector | Vector2 | Vector3): Vector
	if typeof(vec) == "Vector2" then
		return Vector.new(vec.X, vec.Y)
	elseif typeof(vec) == "Vector3" then
		return Vector.new(vec.X, vec.Y, vec.Z)
	end
	return vec
end

function Solver:_Rand(vec: Vector): number
	local scalars = vec:ToScalars()
	local seed = self.Seed
	for i, v in ipairs(scalars) do
		seed += 1 * Random.new(i*v*1000):NextInteger(1, 100000) % (seed / 100)
	end
	return Random.new(seed):NextNumber()
	-- return math.random()
end

function Solver:__newindex(k, v)
	if self[k] ~= nil then
		rawset(self, k, v)
	else
		error(tostring(k).." is not a valid solver property")
	end
end

function Solver:_CopyConfiguration(obj): Solver
	for k, v in pairs(self) do
		if typeof(v) == "number" or typeof(v) == "EnumItem" then
			obj[k] = v
		elseif typeof(v) == "table" then
			local newTabl = {}
			if k == "Octaves" then
				for k2, kv in pairs(v) do
					newTabl[k2] = kv:Clone()
				end
			else
				for k2, kv in pairs(v) do
					newTabl[k2] = kv
				end
			end
			self[k] = newTabl
		end
	end
	return obj
end

function Solver:ToMatrix(size: number)
	local vecs = {}
	local totalDuration = 0
	local totalSolves = 0
	for x=1, size do
		-- if x%5 == 0 then task.wait() end
		local values = {}
		for y=1, size do
			local start = tick()
			values[y] = self:Get(Vector.new(x-1,y-1)/size)
			totalDuration += tick() - start
			totalSolves += 1
		end
		vecs[x] = Vector.new(unpack(values))
	end

	-- print("Average cell compute duration: "..tostring(math.round(1000000*totalDuration/totalSolves)/1000000))

	return Matrix.new(unpack(vecs))
end

function Solver:Debug(parentGui: Frame, scale: number | nil, rMatrix: Matrix, gMatrix: Matrix, bMatrix: Matrix)
	assert(rMatrix ~= nil, "Bad matrix")
	scale = scale or 1
	gMatrix = gMatrix or rMatrix
	bMatrix = bMatrix or gMatrix


	for x, vec in ipairs(rMatrix:ToVectors()) do
		for y, r in ipairs(vec:ToScalars()) do
			local g: number = gMatrix[x][y]
			local b: number = bMatrix[x][y]
			local px: Frame = Instance.new("Frame", parentGui)
			px.Name = tostring(Vector.new(x,y))
			px:SetAttribute("R", r)
			px:SetAttribute("G", g)
			px:SetAttribute("B", b)
			px.BackgroundColor3 = Color3.new(
				math.clamp(r,0,1),
				math.clamp(g,0,1),
				math.clamp(b,0,1)
			)
			px.Position = UDim2.fromOffset(x*scale,y*scale)
			px.AnchorPoint = Vector2.new(0.5,0.5)
			px.Size = UDim2.fromOffset(1*scale,1*scale)
			px.BorderSizePixel = 0
		end
	end

	-- for i, vec in ipairs(highlightPoints) do
	-- 	local str = tostring(vec)
	-- 	local px = parentGui:FindFirstChild(str)
	-- 	if px then
	-- 		px.BackgroundColor3 = Color3.new(1,0,0)
	-- 	end
	-- end
end

function Solver:_Compile(vec: Vector, base: number): number
	local val = 0
	for i, solver in pairs(self.Octaves) do
		val += solver:Get(vec)
	end
	return self.Amplitude * (base + val)
end

function Solver:_UpdateOctaves()
	for power, solver in ipairs(self.Octaves) do
		local freq = self.Frequency * self.Lacunarity ^ power
		local amp = self.Amplitude * self.Persistence ^ power
		solver:Set(nil, freq, amp)
	end
end

function Solver:_TranslatePoints(pointVectors: {[number]: Vector | Vector2 | Vector3})
	local finalPoints = {}
	for i, vec in ipairs(pointVectors) do
		table.insert(finalPoints, Solver.translateVector(vec))
	end
	return finalPoints
end

function Solver:_SetSeparationLimit()
	if #self.Points <= 1 then rawset(self, "SeparationLimit", 0) return end
	local closestDistances = {}
	local function setClosest(p: Vector)
		local points = {}
		local closest
		local cDist = math.huge
		for i, point in ipairs(self.Points) do
			if point ~= p then
				local dist = (point - p).Magnitude
				if not closest or dist < cDist then
					closest = point
					cDist = dist
				end
			end
		end
		table.insert(closestDistances, cDist)
	end
	for i, p in ipairs(self.Points) do
		setClosest(p)
	end
	local maxVal = closestDistances[1]
	for i, v in ipairs(closestDistances) do
		maxVal = math.max(v, maxVal)
	end
	rawset(self, "SeparationLimit", maxVal)
end

function Solver:GeneratePoints(count: number, min: Vector, max: Vector)
	assert(count > 0, "Bad count")
	assert(min ~= nil, "Bad min")
	assert(max ~= nil, "Bad max")

	local limit = max - min
	local rand = Random.new(self.Seed)
	local points = {}
	for i=1, count do
		local values = {}
		for j=1, limit.Size do
			values[j] = min[j] + rand:NextNumber() * limit[j]
		end
		table.insert(points, Vector.new(unpack(values)))
	end
	rawset(self, "Points", points)
	self:_SetSeparationLimit()
end

function Solver:SetPoints(pointVectors: {[number]: Vector | Vector2 | Vector3})
	assert(pointVectors ~= nil,  "Bad point vectors")
	rawset(self, "Points", self:_TranslatePoints(pointVectors))
	self:_SetSeparationLimit()
end

function Solver:InsertOctave(solver: Solver)
	assert(solver ~= nil,  "Bad octave solver")
	table.insert(self.Octaves, solver)
	self:_UpdateOctaves()
end

function Solver:SetPersistence(value: number)
	assert(value ~= nil and type(value) == "number",  "Bad persistence")
	rawset(self, "Persistence", value or self.Persistence)
	self:_UpdateOctaves()
end

function Solver:SetLacunarity(value: number)
	assert(value ~= nil and type(value) == "number",  "Bad lacunarity")
	rawset(self, "Lacunarity", value or self.Lacunarity)
	self:_UpdateOctaves()
end

function Solver:SetAmplitude(value: number)
	assert(value ~= nil and type(value) == "number",  "Bad amplitude")
	rawset(self, "Amplitude", value or self.Amplitude)
	self:_UpdateOctaves()
end

function Solver:SetFrequency(value: number)
	assert(value ~= nil and type(value) == "number",  "Bad frequency")
	rawset(self, "Frequency", value)
	self:_UpdateOctaves()
end


function Solver:SetSeed(seed: number)
	assert(seed ~= nil and type(seed) == "number",  "Bad seed")
	rawset(self, "Seed", seed)
	self:_UpdateOctaves()
end

function Solver:Set(seed: number | nil, frequency: number | nil, amplitude: number | nil, lacunarity: number | nil, persistence: number | nil, pointVectors: {[number]: Vector})
	rawset(self, "Seed", seed or self.Seed)
	rawset(self, "Amplitude", amplitude or self.Amplitude)
	rawset(self, "Frequency", frequency or self.Frequency)
	rawset(self, "Persistence", persistence or self.Persistence)
	rawset(self, "Lacunarity", lacunarity or self.Lacunarity)
	
	if pointVectors then
		rawset(self, "Points", self:_TranslatePoints(pointVectors))
		self:_SetSeparationLimit()
	end

	self:_UpdateOctaves()
end

function Solver:Get(vec: Vector): number
	vec = self.translateVector(vec)
	return self:_Compile(vec, self:_Rand(vec))
end

function Solver:Clone()
	return self:_CopyConfiguration(Solver.new())
end

function Solver.new(seed: number, frequency: number, amplitude: number, lacunarity: number, persistence: number, pointVectors: {[number]: Vector}): Solver
	--http://www.campi3d.com/External/MariExtensionPack/userGuide5R4v1/Understandingsomebasicnoiseterms.html
	local self = setmetatable({
		Seed = tick() :: number,
		Frequency = 1 :: number, --set either manually or by parent solver
		Amplitude = 1 :: number, --set either manually or by parent solver
		Octaves = {} :: {[number]: Solver},
		Lacunarity = 2, --frequency increase rate of octaves
		Persistence = 0.5, --decreasing amplitude of octaves
		Points = {} :: {[number]: Vector},
		SeparationLimit = 0,
	}, Solver)
	self:Set(seed, frequency, amplitude, lacunarity, persistence, pointVectors)
	return self
end

export type Solver = typeof(Solver.new())

return Solver