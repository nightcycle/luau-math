--imagine a vector2 or 3, except unlimited dimensions
local Vector = {}

function Vector:__index(k)
	if k == "_scalars" then error("Don't try to index private variables") end
	if k == "Unit" then
		local maxScalar = 0
		for i, v in ipairs(rawget(self, "_scalars")) do
			maxScalar = math.max(maxScalar, math.abs(v))
		end
		local newScalars = {}
		for i, v in ipairs(rawget(self, "_scalars")) do
			newScalars[i] = v/maxScalar
		end
		return Vector.new(unpack(newScalars))
	else
		return rawget(self, k) or rawget(self, "_scalars")[k] or rawget(Vector, k)
	end
end

function Vector:__newindex(k,v)
	error("You can't change values of this vector post-construction")
end

function Vector:__add(v) --add
	local sum = {}
	for i, s in ipairs(rawget(self, "_scalars")) do
		if type(v) == "table" and v.Type == "Vector" then
			sum[i] = s + (v[i] or 0)
		else
			sum[i] = s + v
		end
	end
	return Vector.new(unpack(sum))
end

function Vector:__sub(v) --subtract
	local difference = {}
	for i, s in ipairs(rawget(self, "_scalars")) do
		if type(v) == "table" and v.Type == "Vector" then
			difference[i] = s - (v[i] or 0)
		else
			difference[i] = s - v
		end
	end
	return Vector.new(unpack(difference))
end

function Vector:__mul(v) --multiply
	if typeof(v) == "table" then
		local product = {}
		for i, s in ipairs(rawget(self, "_scalars")) do
			product[i] = s * v[i]
		end
		return Vector.new(unpack(product))
	elseif typeof(v) == "number" then
		local product = {}
		for i, s in ipairs(rawget(self, "_scalars")) do
			product[i] = s * v
		end
		return Vector.new(unpack(product))
	else
		error("Bad value")
	end
end

function Vector:__div(v) --divide
	if typeof(v) == "table" then
		local quotient = {}
		for i, s in ipairs(rawget(self, "_scalars")) do
			quotient[i] = s / v[i]
		end
		return Vector.new(unpack(quotient))
	elseif typeof(v) == "number" then
		local quotient = {}
		for i, s in ipairs(rawget(self, "_scalars")) do
			quotient[i] = s / v
		end
		return Vector.new(unpack(quotient))
	else
		error("Bad value")
	end
end

function Vector:__pow(v) --power
	if typeof(v) == "table" then
		local result = {}
		for i, s in ipairs(rawget(self, "_scalars")) do
			result[i] = s ^ v[i]
		end
		return Vector.new(unpack(result))
	elseif typeof(v) == "number" then
		local result = {}
		for i, s in ipairs(rawget(self, "_scalars")) do
			result[i] = s ^ v
		end
		return Vector.new(unpack(result))
	else
		error("Bad value")
	end
end

function Vector:__mod(v) --mod
	if typeof(v) == "table" then
		local result = {}
		for i, s in ipairs(rawget(self, "_scalars")) do
			result[i] = s % v[i]
		end
		return Vector.new(unpack(result))
	elseif typeof(v) == "number" then
		local result = {}
		for i, s in ipairs(rawget(self, "_scalars")) do
			result[i] = s % v
		end
		return Vector.new(unpack(result))
	else
		error("Bad value")
	end
end

function Vector:__eq(v) --equal
	if v == false then return false end
	if typeof(v) == "table" and v.Type == "Vector" then
		for i, s in ipairs(rawget(self, "_scalars")) do
			if s ~= v[i] then return false end
		end
		return true
	else
		return false
	end
end

function Vector:__tostring()
	local scalars = self:ToScalars()
	local str = ""
	for i, v in ipairs(scalars) do
		if i ~= 1 then
			str = str.."\n"
		end
		str = str..tostring(v)..","
	end
	return str
end

function Vector:Round(pow)
	local newScalars = {}
	local weight = 10^(pow or 0)
	for i, s in ipairs(rawget(self, "_scalars")) do
		newScalars[i] = math.round(s * weight)/weight
	end
	return Vector.new(unpack(newScalars))
end

function Vector:ToScalars()
	local result = {}
	for i, v in ipairs(rawget(self, "_scalars")) do
		table.insert(result, v)
	end
	return result
end

function Vector:Floor(pow)
	local newScalars = {}
	local weight = 10^(pow or 0)
	for i, s in ipairs(rawget(self, "_scalars")) do
		newScalars[i] = math.floor(s / weight)*weight
	end
	return Vector.new(unpack(newScalars))
end

function Vector:Ceil(pow)
	local newScalars = {}
	local weight = 10^(pow or 0)
	for i, s in ipairs(rawget(self, "_scalars")) do
		newScalars[i] = math.ceil(s / weight)*weight
	end
	return Vector.new(unpack(newScalars))
end


-- @TODO
function Vector:Cross()

end

-- @TODO
function Vector:Dot()

end

function Vector:Lerp(goal, alpha)
	local product = {}
	for i, s in ipairs(rawget(self, "_scalars")) do
		product[i] = s + (goal[i] - s)*alpha
	end
	return Vector.new(unpack(product))
end

function Vector:ToVector3()
	local scalars = self:ToScalars()
	return Vector3.new(scalars[1], scalars[2], scalars[3])
end

function Vector:ToVector2()
	local scalars = self:ToScalars()
	return Vector3.new(scalars[1], scalars[2])
end

function Vector:Clone()
	return Vector.new(unpack(rawget(self, "_scalars")))
end

function Vector.zero(size)
	local params = {}
	for i=1, size do
		table.insert(params, i)
	end
	return Vector.new(unpack(params))
end

function Vector.fromVector3(v3)
	return Vector.new(v3.X, v3.Y, v3.Z)
end

function Vector.fromVector2(v2)
	return Vector.new(v2.X, v2.Y)
end

function Vector.one(size)
	local vals = {}
	for i=1, size do
		table.insert(vals, 1)
	end
	return Vector.new(unpack(vals))
end

function Vector.identity(size, index)
	local vals = {}
	for i=1, size do
		if i == index then
			table.insert(vals, 1)
		else
			table.insert(vals, 0)
		end	
	end
	return Vector.new(unpack(vals))
end

function Vector.new(...)
	local self = {}

	self._scalars = {...}
	self.Size = #self._scalars
	self.Type = "Vector"

	self.Magnitude = 0

	--iterate through each scalar value, solving the hypotenuse of each new dimension
	local function solveMagnitude(i, prevHyp)
		i = i or 1
		i += 1
		local a = prevHyp or self._scalars[i-1]
		local b = self._scalars[i]
		if b then
			return solveMagnitude(i, (a^2 + b^2)^2)
		else
			return a
		end
	end
	solveMagnitude()

	setmetatable(self, Vector)

	return self
end

return Vector