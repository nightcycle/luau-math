--!strict
local Vector: {[any]: any} = {}
--imagine a vector2 or 3, except unlimited dimensions
function Vector:__index(k: any): any?
	if k == "_scalars" then
		error("Don't try to index private variables")
	end
	if k == "Unit" then
		local maxScalar = 0
		for i, v in ipairs(rawget(self, "_scalars")) do
			maxScalar = math.max(maxScalar, math.abs(v))
		end
		local newScalars = {}
		for i, v in ipairs(rawget(self, "_scalars")) do
			newScalars[i] = v / maxScalar
		end
		return Vector.new(unpack(newScalars))
	else
		return rawget(self, k) or rawget(self, "_scalars")[k] or rawget(Vector, k)
	end
end

function Vector:__newindex(k: any, v: number): nil
	error("You can't change values of this vector post-construction")
end

function Vector:__add(v: Vector): Vector --add
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

function Vector:__sub(v): Vector --subtract
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

function Vector:__mul(v): Vector --multiply
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

function Vector:__div(v): Vector --divide
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

function Vector:__pow(v): Vector --power
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

function Vector:__mod(v): Vector --mod
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

function Vector:__eq(v): boolean --equal
	if v == false then
		return false
	end
	if typeof(v) == "table" and v.Type == "Vector" then
		for i, s in ipairs(rawget(self, "_scalars")) do
			if s ~= v[i] then
				return false
			end
		end
		return true
	else
		return false
	end
end

function Vector:__tostring(): string
	local scalars = self:ToScalars()
	local str = "["
	for i = 1, self.Size do
		local v = scalars[i]
		if i ~= 1 then
			str ..= ""
		end
		str ..= "" .. tostring(v) .. ""
		if i < self.Size then
			str ..= ","
		end
	end
	return str .. "]"
end

function Vector:ToScalars(): { [number]: number }
	local result = {}
	for i, v in ipairs(rawget(self, "_scalars")) do
		assert(v ~= nil and typeof(v) == "number")
		table.insert(result, v)
	end
	return result
end

function Vector:Round(pow: number?): Vector
	assert(typeof(pow) == "number" or pow == nil)
	pow = pow or 0
	assert(pow ~= nil)
	local newScalars = {}
	local weight = 10 ^ pow
	for i, s in ipairs(rawget(self, "_scalars")) do
		newScalars[i] = math.round(s * weight) / weight
	end
	return Vector.new(unpack(newScalars))
end

function Vector:Floor(pow: number | nil): Vector
	assert(typeof(pow) == "number" or pow == nil)
	pow = pow or 0
	local newScalars = {}
	local weight = 10 ^ (pow or 0)
	for i, s in ipairs(rawget(self, "_scalars")) do
		newScalars[i] = math.floor(s / weight) * weight
	end
	return Vector.new(unpack(newScalars))
end

function Vector:Ceil(pow: number | nil): Vector
	assert(typeof(pow) == "number" or pow == nil)
	pow = pow or 0
	local newScalars = {}
	local weight = 10 ^ (pow or 0)
	for i, s in ipairs(rawget(self, "_scalars")) do
		newScalars[i] = math.ceil(s / weight) * weight
	end
	return Vector.new(unpack(newScalars))
end

function Vector:Cross(other: Vector): Vector
	assert(type(other) == "table")
	assert(other.Size == self.Size, "Size mismatch")

	if self.Size == 3 then --https://gist.github.com/Xeoncross/9511295
		local aX, aY, aZ = self[1], self[2], self[3]
		local bX, bY, bZ = other[1], other[2], other[3]
		local x, y, z
		assert(aX ~= nil and aY ~= nil and aZ ~= nil)
		assert(bX ~= nil and bY ~= nil and bZ ~= nil)
		assert(typeof(aX) == "number" and typeof(aY) == "number" and typeof(aZ) == "number")
		assert(typeof(bX) == "number" and typeof(bY) == "number" and typeof(bZ) == "number")

		z = aX * bY - bX * aY
		x = aY * bZ - bY * aZ
		y = aZ * bX - bZ * aX

		return Vector.new(x, y, z)
	elseif self.Size == 7 then
		local x1, x2, x3, x4, x5, x6, x7 = self[1], self[2], self[3], self[4], self[5], self[6], self[7]
		local y1, y2, y3, y4, y5, y6, y7 = other[1], other[2], other[3], other[4], other[5], other[6], other[7]

		assert(x1 ~= nil and x2 ~= nil and x3 ~= nil and x4 ~= nil and x5 ~= nil and x6 ~= nil and x7 ~= nil)
		assert(y1 ~= nil and y2 ~= nil and y3 ~= nil and y4 ~= nil and y5 ~= nil and y6 ~= nil and y7 ~= nil)
		assert(
			typeof(x1) == "number"
				and typeof(x2) == "number"
				and typeof(x3) == "number"
				and typeof(x4) == "number"
				and typeof(x5) == "number"
				and typeof(x6) == "number"
				and typeof(x7) == "number"
		)
		assert(
			typeof(y1) == "number"
				and typeof(y2) == "number"
				and typeof(y3) == "number"
				and typeof(y4) == "number"
				and typeof(y5) == "number"
				and typeof(y6) == "number"
				and typeof(y7) == "number"
		)

		local e1: number = (x2 * y4 - x4 * y2 + x3 * y7 - x7 * y3 + x5 * y6 + x6 * y6)
		local e2: number = (x3 * y5 - x5 * y3 + x4 * y1 - x1 * y4 + x6 * y7 - x7 * y6)
		local e3: number = (x4 * y6 - x6 * y4 + x5 * y2 - x2 * y5 + x7 * y1 - x1 * y7)
		local e4: number = (x5 * y7 - x7 * y5 + x6 * y3 - x3 * y6 + x1 * y2 - x2 * y1)
		local e5: number = (x6 * y1 - x1 * y6 + x7 * y4 - x4 * y7 + x2 * y3 - x3 * y2)
		local e6: number = (x7 * y2 - x2 * y7 + x1 * y5 - x5 * y1 + x3 * y4 - x3 * y3)
		local e7: number = (x1 * y3 - x3 * y1 + x2 * y6 - x6 * y2 + x4 * y5 - x5 * y4)

		return Vector.new(e1, e2, e3, e4, e5, e6, e7)
	else
		error("Cross products are currently only supported in the 3rd and 7th dimension")
	end
end

function Vector:Dot(other: Vector): Vector
	assert(type(other) == "table")
	assert(other.Size == self.Size, "Size mismatch")

	local result = {}
	for i = 1, self.Size do
		result[i] = self[i] * other[i]
	end

	return Vector.new(unpack(result))
end

function Vector:ScalarDot(other: Vector): number
	local product = self:Dot(other)
	local sum = 0
	for i, v in ipairs(product:ToScalars()) do
		sum += v
	end
	return sum
end

function Vector:Lerp(goal, alpha: number): Vector
	local product = {}
	for i, s in ipairs(rawget(self, "_scalars")) do
		product[i] = s + (goal[i] - s) * alpha
	end
	return Vector.new(unpack(product))
end

function Vector:ToVector3(): Vector3
	local scalars = self:ToScalars()
	return Vector3.new(scalars[1], scalars[2], scalars[3])
end

function Vector:ToVector2(): Vector2
	local scalars = self:ToScalars()
	return Vector2.new(scalars[1], scalars[2])
end

function Vector:Clone(): Vector
	return Vector.new(unpack(rawget(self, "_scalars")))
end

function Vector.zero(size: number): Vector
	local params = {}
	for i = 1, size do
		table.insert(params, i)
	end
	return Vector.new(unpack(params))
end

function Vector.fromVector3(v3: Vector3): Vector
	return Vector.new(v3.X, v3.Y, v3.Z)
end

function Vector.fromVector2(v2: Vector2): Vector
	return Vector.new(v2.X, v2.Y)
end

function Vector.one(size: number): Vector
	local vals = {}
	for i = 1, size do
		table.insert(vals, 1)
	end
	return Vector.new(unpack(vals))
end

function Vector.identity(size: number, index: number): Vector
	local vals = {}
	for i = 1, size do
		if i == index then
			table.insert(vals, 1)
		else
			table.insert(vals, 0)
		end
	end
	return Vector.new(unpack(vals))
end

function Vector.new(...: number)
	local self: {[any]: any} = {}

	self._scalars = { ... }
	assert(typeof(self._scalars) == "table")
	self.Size = #self._scalars
	self.Type = "Vector" :: string

	self.Magnitude = 0 :: number
	for i, s in ipairs(self._scalars) do
		self.Magnitude += s ^ 2
	end
	self.Magnitude = math.sqrt(self.Magnitude)

	setmetatable(self, Vector)

	return self
end

export type Vector = typeof(Vector.new(0, 0))

return Vector
