-- imagine a cframe that works with unlimited dimensions
local Matrix = {}
local Vector = require(script.Parent:WaitForChild("Vector"))

function Matrix:__index(k)
	if k == "_vectors" then error("Don't try to index private variables") end
	return rawget(self, k) or rawget(self, "_vectors")[k] or rawget(Matrix, k)
end

function Matrix:__newindex(k,v)
	error("You can't change values of this vector post-construction")
end

function Matrix:GetDeterminant()
	-- https://github.com/davidm/lua-matrix/blob/master/lua/matrix.lua
	--[[
		LICENSE
	
		Licensed under the same terms as Lua itself.
		
		Developers:
		Michael Lutz (chillcode) - original author
		David Manura http://lua-users.org/wiki/DavidManura
	--]]

	-- check if matrix is quadratic
	assert(self.Dimensions[1] == self.Dimensions[2], "matrix not square")
	
	local size = self.Dimensions[1]
	
	if size == 1 then
		return self[1][1]
	end
	
	if size == 2 then
		return self[1][1]*self[2][2] - self[2][1]*self[1][2]
	end
	
	if size == 3 then
		return (
			self[1][1]*self[2][2]*self[3][3]
			+ self[1][2]*self[2][3]*self[3][1]
			+ self[1][3]*self[2][1]*self[3][2]
			- self[1][3]*self[2][2]*self[3][1]
			- self[1][1]*self[2][3]*self[3][2]
			- self[1][2]*self[2][1]*self[3][3]
		)
	end
	
	--no symbolic matrix supported below here
	local e = self[1][1]
	local zero  = type(e) == "table" and e.zero or 0
	local norm2 = type(e) == "table" and e.norm2

	-- matrix is bigger than 3x3
		-- get determinant
		-- using Gauss elimination and Laplace
		-- start eliminating from below better for removals
		-- get copy of matrix, set initial determinant
	local mtx = {}
	for i, vec in ipairs(self:GetVectors()) do
		for j, scalar in ipairs(vec:GetScalars()) do
			mtx[j] = mtx[j] or {}
			mtx[j][i] = scalar
		end
	end
	local det = 1
	-- get det up to the last element
	for j = 1,#mtx[1] do
		-- get smallest element so that |factor| > 1
		-- and set it as last element
		local rows = #mtx
		local subdet, xrow
		for i = 1,rows do
			-- get element
			local e = mtx[i][j]
			-- if no subdet has been found
			if not subdet then
				-- check if element it is not zero
				if e ~= zero then
					-- use element as new subdet
					subdet,xrow = e,i
				end
			-- check for elements nearest to 1 or -1
			elseif e ~= zero and math.abs(norm2(e)-1) < math.abs(norm2(subdet)-1) then
				subdet,xrow = e,i
			end
		end
		-- only cary on if subdet is found
		if subdet then
			-- check if xrow is the last row,
			-- else switch lines and multiply det by -1
			if xrow ~= rows then
				mtx[rows],mtx[xrow] = mtx[xrow],mtx[rows]
				det = -det
			end
			-- traverse all fields setting element to zero
			-- we don't set to zero cause we don't use that column anymore then anyways
			for i = 1,rows-1 do
				-- factor is the dividor of the first element
				-- if element is not already zero
				if mtx[i][j] ~= zero then
					local factor = mtx[i][j]/subdet
					-- update all remaining fields of the matrix, with value from xrow
					for n = j+1,#mtx[1] do
						mtx[i][n] = mtx[i][n] - factor * mtx[rows][n]
					end
				end
			end

			-- update determinant and remove row
			if math.fmod(rows,2) == 0 then
				det = -det
			end
			det = det * subdet
			table.remove( mtx )
		else
			-- break here table det is 0
			return det * 0
		end
	end
	-- det ready to return
	return det
end

-- function Matrix:GetEigen()
-- 	-- https://www.youtube.com/watch?v=PFDu9oVAE-g


-- 	local determinant = self:GetDeterminant()

-- 	local function lambdaTry(lambda: number)
-- 		local lMatrix = Matrix.identity(self.Dimensions)*lambda
-- 		local dif = self - lMatrix
-- 		return dif:GetDeterminant()
-- 	end

-- 	local function lambdaCheck(lambda: number)
-- 		return lambdaTry(lambda) == 0
-- 	end

-- 	local function getEigenValues() --(x11-lambda)(x22-lambda)(x33etc-lambda) = 0
-- 		local values = {}
-- 		for x, column in ipairs(self:GetVectors()) do
-- 			for y, scal in ipairs(column:GetScalars()) do
-- 				if y == x then
-- 					if lambdaCheck(scal) and scal ~= 0 then
-- 						table.insert(values, scal)
-- 					end
-- 				end
-- 			end
-- 		end
-- 		return values
-- 	end


-- 	local function vectorTry(vector,  lambda)
-- 		local lMatrix = Matrix.identity(self.Dimensions)*lambda
-- 		return vector*(self-lMatrix)
-- 	end

-- 	local function vectorCheck()
-- 		return vectorTry.Magnitude == 0
-- 	end

-- 	local function getEigenVectors(eigVals)
-- 		local vectors = {}
-- 		for i, lambda in ipairs(eigVals) do
-- 			-- local lMatrix = Matrix.identity(self.Dimensions)*lambda
-- 			-- lamda * ? * self = 0
-- 		end
-- 		return vectors
-- 	end
-- 	local eigenValues = getEigenValues()
-- 	local eigenVectors = getEigenVectors(eigenValues)

-- 	return eigenVectors, eigenValues
-- end

function Matrix:__add(v) --add
	local sum = {}
	for i, s in ipairs(rawget(self, "_vectors")) do
		if typeof(v) == "table" and v.Type == "Matrix" then	
			sum[i] = s + v[i]
		else
			sum[i] = s + v
		end
	end
	return Matrix.new(unpack(sum))
end

function Matrix:__sub(v) --subtract
	local difference = {}
	for i, s in ipairs(rawget(self, "_vectors")) do
		if typeof(v) == "table" and v.Type == "Matrix" then
			difference[i] = s - v[i]
		else
			difference[i] = s - v
		end
	end
	return Matrix.new(unpack(difference))
end

function Matrix:__mul(v) --multiply
	if typeof(v) == "table" then
		if v.Type == "Matrix" then
			assert(self.Dimensions[1] == self.Dimensions[2], "Bad square matrix")
			assert(v.Dimensions == self.Dimensions, "Bad matrix match")
			local product = {}
			local vColumns = v:ToVectors()

			for y, row in ipairs(self:ToRows()) do
				local baseWeights = row:ToScalars()
				product[y] = product[y] or {}
				for x, _ in ipairs(baseWeights) do
					local sum = 0
					local multWeights = vColumns[x]:ToScalars()
					for i, bScal in ipairs(baseWeights) do
						sum += bScal * multWeights[i]
					end
					product[y][x] = sum
				end
				product[y] = Vector.new(unpack(product[y]))
			end
			product = Matrix.fromRows(unpack(product))

			return product
		elseif v.Type == "Vector" then
			error("Currently vector x matrix multiplication isn't supported")
		end
	elseif typeof(v) == "number" then
		local result = {}
		for i, s in ipairs(rawget(self, "_vectors")) do
			result[i] = s * v
		end
		return Matrix.new(unpack(result))
	else
		error("Bad value")
	end
end

function Matrix:__div(v) --divide
	if typeof(v) == "table" and v.Type == "Matrix" then
		error("I didn't code matrix division")
	elseif typeof(v) == "number" then
		local quotient = {}
		for i, s in ipairs(rawget(self, "_vectors")) do
			quotient[i] = s / v
		end
		return Matrix.new(unpack(quotient))
	else
		error("Bad value")
	end
end

function Matrix:__pow(v) --power
	if typeof(v) == "table" then
		local result = {}
		for i, s in ipairs(rawget(self, "_vectors")) do
			result[i] = s ^ v[i]
		end
		return Matrix.new(unpack(result))
	elseif typeof(v) == "number" then
		local result = {}
		for i, s in ipairs(rawget(self, "_vectors")) do
			result[i] = s ^ v
		end
		return Matrix.new(unpack(result))
	else
		error("Bad value")
	end
end

function Matrix:__mod(v) --mod
	if typeof(v) == "table" then
		local result = {}
		for i, s in ipairs(rawget(self, "_vectors")) do
			result[i] = s % v[i]
		end
		return Matrix.new(unpack(result))
	elseif typeof(v) == "number" then
		local result = {}
		for i, s in ipairs(rawget(self, "_vectors")) do
			result[i] = s % v
		end
		return Matrix.new(unpack(result))
	else
		error("Bad value")
	end
end

function Matrix:__eq(v) --equal
	if v == false then return false end
	if typeof(v) == "table" and v.Type == "Matrix" then
		for i, s in ipairs(rawget(self, "_vectors")) do
			if s ~= v[i] then return false end
		end
		return true
	else
		return false
	end
end

function Matrix:ToVectors()
	local vecs = {}
	for i, vec in ipairs(rawget(self, "_vectors")) do
		table.insert(vecs, vec)
	end
	return vecs
end

function Matrix:ToRows()
	local rows = {}
	for i, vec in ipairs(rawget(self, "_vectors")) do
		for vI, s in ipairs(vec:ToScalars()) do
			rows[vI] = rows[vI] or {}
			table.insert(rows[vI], s)
		end
	end
	for i, vec in ipairs(rows) do
		rows[i] = Vector.new(unpack(vec))
	end
	-- print(rows)
	return rows
end

function Matrix:Transpose()
	local vectors = self:ToRows()
	return Matrix.new(unpack(vectors))
end

function Matrix:__tostring()
	local str = ""
	local rows = self:ToRows()
	for i, row in ipairs(rows) do
		local rowStr = ""
		if i ~= 1 then
			rowStr = rowStr.."\n"
		end
		for j, s in ipairs(row) do
			if j ~= 1 then
				rowStr = rowStr.."|"..tostring(s)
			else
				rowStr = tostring(s)
			end
		end
		str = str..rowStr
	end
	return str
end

function Matrix.fromRows(...)
	local orig = Matrix.new(...)

	return orig:Transpose()
end

function Matrix.one(dimensions)
	local vecs = {}
	for i=1, dimensions[1] do
		table.insert(vecs, Vector.one(dimensions[2]))
	end
	return Vector.new(unpack(vecs))
end

function Matrix.identity(dimensions)
	local vecs = {}
	for i=1, dimensions[1] do
		table.insert(vecs, Vector.identity(dimensions[2], i))
	end
	return Vector.new(unpack(vecs))
end

function Matrix.new(...)
	local self = {}

	self._vectors = {...}
	-- print(self._vectors)
	self.Dimensions = Vector.new(#self._vectors, self._vectors[1].Size)
	self.Type = "Matrix"
	self.Magnitude = 0
	for i, vec in ipairs(self._vectors) do
		self.Magnitude += vec.Magnitude
	end

	setmetatable(self, Matrix)

	return self
end

return Matrix