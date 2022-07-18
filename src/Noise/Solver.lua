--!strict
local Vector = require(script.Parent.Parent.Algebra.Vector)
type Vector = Vector.Vector

local Solver: {[any]: any} = {}
Solver.__index = Solver

local Matrix = require(script.Parent.Parent.Algebra.Matrix)
type Matrix = Matrix.Matrix

function Solver.translateVector(vec: Vector | Vector2 | Vector3): Vector
	assert(vec ~= nil)
	if typeof(vec) == "Vector2" then
		return Vector.new(vec.X, vec.Y)
	elseif typeof(vec) == "Vector3" then
		return Vector.new(vec.X, vec.Y, vec.Z)
	end
	assert(typeof(vec) ~= "Vector2" and typeof(vec) ~= "Vector3")
	assert(getmetatable(vec) == Vector)
	return vec
end

function Solver:__newindex(k, v): nil
	if self[k] ~= nil then
		rawset(self, k, v)
	else
		error(tostring(k) .. " is not a valid solver property")
	end
	return nil
end

function Solver:_Rand(vec: Vector): number
	local scalars = vec:ToScalars()
	local seed: number = self.Seed
	for i, v in ipairs(scalars) do
		seed += 1 * Random.new(i * v * 1000):NextInteger(1, 100000) % (seed / 100)
	end
	return Random.new(seed):NextNumber()
end

function Solver:_SetSeparationLimit(): nil
	local points: { [number]: Vector } = self.Points
	if #points <= 1 then
		rawset(self, "SeparationLimit", 0)
		return nil
	end

	local closestDistances = {}
	local function setClosest(p: Vector)
		local closest
		local cDist = math.huge
		for i, point: Vector in ipairs(points) do
			assert(getmetatable(point) == Vector)
			if Vector.__eq(point, p) then
				local offset: Vector = Vector.__sub(point, p)
				local dist: number = offset.Magnitude
				if dist and (not closest or dist < cDist) then
					closest = point
					cDist = dist
				end
			end
		end
		table.insert(closestDistances, cDist)
	end
	for i, p in ipairs(points) do
		setClosest(p)
	end
	local maxVal = closestDistances[1]
	for i, v in ipairs(closestDistances) do
		maxVal = math.max(v, maxVal)
	end
	rawset(self, "SeparationLimit", maxVal)
	return nil
end

function Solver:_CopyConfiguration(solver: NoiseSolver): nil
	for k, v in pairs(self) do
		if typeof(v) == "number" or typeof(v) == "EnumItem" then
			solver[k] = v
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
	return nil
end

function Solver:ToMatrix(size: number): Matrix
	local vecs = {}
	local totalDuration = 0
	local totalSolves = 0
	for x = 1, size do
		local values = {}
		for y = 1, size do
			local start = tick()
			values[y] = self:Get(Vector.new(x - 1, y - 1) / size)
			totalDuration += tick() - start
			totalSolves += 1
		end
		vecs[x] = Vector.new(unpack(values))
	end

	return Matrix.new(unpack(vecs))
end

function Solver:Debug(parentGui: Frame, scale: number?, rMatrix: Matrix, gMatrix: Matrix, bMatrix: Matrix): nil
	
	scale = scale or 1
	assert(scale ~= nil)
	gMatrix = gMatrix or rMatrix
	bMatrix = bMatrix or gMatrix

	for x, vec in ipairs(rMatrix:ToVectors()) do
		for y, r in ipairs(vec:ToScalars()) do
			local g: number = gMatrix[x][y]
			local b: number = bMatrix[x][y]
			local px: Frame = Instance.new("Frame")
			px.Name = tostring(Vector.new(x, y))
			px:SetAttribute("R", r)
			px:SetAttribute("G", g)
			px:SetAttribute("B", b)
			px.BackgroundColor3 = Color3.new(math.clamp(r, 0, 1), math.clamp(g, 0, 1), math.clamp(b, 0, 1))
			px.Position = UDim2.fromOffset(x * scale, y * scale)
			px.AnchorPoint = Vector2.new(0.5, 0.5)
			px.Size = UDim2.fromOffset(1 * scale, 1 * scale)
			px.BorderSizePixel = 0
			px.Parent = parentGui
		end
	end
	return nil
end

function Solver:_Compile(vec: Vector, base: number): number
	local val = 0
	for i, solver in pairs(self.Octaves) do
		val += solver:Get(vec)
	end
	return self.Amplitude * (base + val)
end

function Solver:_UpdateOctaves(): nil
	for power, solver in ipairs(self.Octaves) do
		local frequency: number = self.Frequency
		local lacunarity: number = self.Lacunarity
		local amplitude: number = self.Amplitude
		local persistence: number = self.Persistence

		local freq: number = frequency * lacunarity ^ power
		local amp: number = amplitude * persistence ^ power
		solver:Set(nil, freq, amp)
	end
	return nil
end

function Solver:_TranslatePoints(pointVectors: { [number]: Vector | Vector2 | Vector3 }): {[number]: Vector}
	local finalPoints: {[number]: Vector} = {}
	for i, vec in ipairs(pointVectors) do
		table.insert(finalPoints, Solver.translateVector(vec))
	end
	return finalPoints
end

function Solver:GeneratePoints(count: number, min: Vector, max: Vector): nil
	assert(count > 0, "Bad count")
	assert(getmetatable(min) == Vector)
	assert(getmetatable(max) == Vector)

	local limit: Vector = Vector.__sub(max, min)
	local rand = Random.new(self.Seed)
	local points = {}
	for i = 1, count do
		local values = {}
		for j = 1, limit.Size do
			values[j] = min[j] + rand:NextNumber() * limit[j]
		end
		table.insert(points, Vector.new(unpack(values)))
	end
	rawset(self, "Points", points)
	self:_SetSeparationLimit()
	return nil
end

function Solver:SetPoints(pointVectors: { [number]: Vector | Vector2 | Vector3 }): nil
	assert(pointVectors ~= nil, "Bad point vectors")
	rawset(self, "Points", self:_TranslatePoints(pointVectors))
	self:_SetSeparationLimit()
	return nil
end

function Solver:InsertOctave(solver: NoiseSolver): nil
	assert(solver ~= nil, "Bad octave solver")
	table.insert(self.Octaves, solver)
	self:_UpdateOctaves()
	return nil
end

function Solver:SetPersistence(value: number): nil
	assert(value ~= nil and type(value) == "number", "Bad persistence")
	rawset(self, "Persistence", value or self.Persistence)
	self:_UpdateOctaves()
	return nil
end

function Solver:SetLacunarity(value: number): nil
	assert(value ~= nil and type(value) == "number", "Bad lacunarity")
	rawset(self, "Lacunarity", value or self.Lacunarity)
	self:_UpdateOctaves()
	return nil
end

function Solver:SetAmplitude(value: number): nil
	assert(value ~= nil and type(value) == "number", "Bad amplitude")
	rawset(self, "Amplitude", value or self.Amplitude)
	self:_UpdateOctaves()
	return nil
end

function Solver:SetFrequency(value: number): nil
	assert(value ~= nil and type(value) == "number", "Bad frequency")
	rawset(self, "Frequency", value)
	self:_UpdateOctaves()
	return nil
end

function Solver:SetSeed(seed: number): nil
	assert(seed ~= nil and type(seed) == "number", "Bad seed")
	rawset(self, "Seed", seed)
	self:_UpdateOctaves()
	return nil
end

function Solver:Get(vec: Vector): number
	vec = self.translateVector(vec)
	return self:_Compile(vec, self:_Rand(vec))
end

function Solver:Clone(): NoiseSolver
	local solver: NoiseSolver = Solver.new()
	assert(getmetatable(solver) == Solver)
	return Solver:_CopyConfiguration(solver, self)
end

function Solver:Set(
	seed: number?,
	frequency: number?,
	amplitude: number?,
	lacunarity: number?,
	persistence: number?,
	pointVectors: { [number]: Vector}?
): nil
	rawset(self, "Seed", seed or self.Seed)
	rawset(self, "Amplitude", amplitude or self.Amplitude)
	rawset(self, "Frequency", frequency or self.Frequency)
	rawset(self, "Persistence", persistence or self.Persistence)
	rawset(self, "Lacunarity", lacunarity or self.Lacunarity)

	if pointVectors then
		local points: {[number]: Vector} = self:_TranslatePoints(pointVectors)
		rawset(self, "Points", points)
		self:_SetSeparationLimit()
	end

	self:_UpdateOctaves()
	return nil
end

function Solver._new()
	local self: {[string]: any} = {
		Seed = 1,
		Frequency = 1, --set either manually or by parent solver
		Amplitude = 1, --set either manually or by parent solver
		Octaves = {} :: {[any]: NoiseSolver},
		Lacunarity = 1, --frequency increase rate of octaves
		Persistence = 1, --decreasing amplitude of octaves
		Points = {} :: {[any]: Vector},
		SeparationLimit = 0,
	}
	
	setmetatable(self, Solver)

	return self
end

function Solver.new(
	seed: number?,
	frequency: number?,
	amplitude: number?,
	lacunarity: number?,
	persistence: number?,
	pointVectors: { [number]: any }?
)
	local solver: NoiseSolver = Solver._new()
	assert(getmetatable(solver) == Solver)
	
	solver:Set(
		seed,
		frequency,
		amplitude,
		lacunarity,
		persistence,
		pointVectors
	)
	return solver
end

export type NoiseSolver = typeof(Solver._new())

return Solver
