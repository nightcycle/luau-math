--!strict

-- imagine a cframe that works with unlimited dimensions
local Matrix = {}

local Vector = require(script.Parent:WaitForChild("Vector"))

type Vector = {
	GetScalars: () -> {[number]: number},
	Type: string,
	__add: () -> Vector,
	[number]: number,
}

function Matrix.new(...: Vector): Matrix
	local self = {}

	self._vectors = {...} :: {[number]: Vector}
	-- print(self._vectors)
	local xDim: number = #self._vectors
	local yDim: number = self._vectors[1].Size

	self.Dimensions = Vector.new(xDim, yDim)

	self.Type = "Matrix"

	self.Magnitude = 0
	for i, vec in ipairs(self._vectors) do
		self.Magnitude += vec.Magnitude
	end

	setmetatable(self, Matrix)

	return self
end


function Matrix:__index(k)
	if k == "_vectors" then error("Don't try to index private variables") end
	return rawget(self, k) or rawget(self, "_vectors")[k] or rawget(Matrix, k)
end

function Matrix:__newindex(k,v)
	error("You can't change values of this vector post-construction")
end

function Matrix:ToVectors(): {[number]: Vector}
	local vecs = {}
	for i, vec in ipairs(rawget(self, "_vectors")) do
		table.insert(vecs, vec)
	end
	return vecs
end


function Matrix:GetDeterminant(): number
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
		local v11: number = self[1][1]
		local v22: number = self[2][2]
		local v21: number = self[2][1]
		local v12: number = self[1][2]
		return v11*v22 - v21*v12
	end
	
	if size == 3 then
		local v11: number = self[1][1]
		local v12: number = self[1][2]
		local v13: number = self[1][3]

		local v21: number = self[2][1]
		local v22: number = self[2][2]
		local v23: number = self[2][3]

	
		local v31: number = self[3][1]
		local v32: number = self[2][3]
		local v33: number = self[3][3]


		return (
			v11*v22*v33
			+ v12*v23*v31
			+ v13*v21*v32
			- v13*v22*v31
			- v11*v23*v32
			- v12*v21*v33
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
	local mtx: {[number]: {[number]: number}} = {}
	local vecs: {[number]: Vector} = self:ToVectors()
	for i, vec: Vector in ipairs(vecs) do
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

function Matrix:__add(vMatVec: Matrix | Vector) --add
	local sumVectors: {[number]: Vector} = {}
	for i, mVec: Vector in ipairs(rawget(self, "_vectors")) do
		local vType: string = vMatVec.Type
		local vVecOrVal: Vector | number = vMatVec[i]
		if typeof(vVecOrVal) == "table" and vType == "Matrix" then
			assert(typeof(vVecOrVal) ~= "number")
			local vVec: Vector = vVecOrVal
			local sumVec: Vector = mVec + vVec
			sumVectors[i] = sumVec
		else
			assert(typeof(vVecOrVal) == "number")
			local val:number = vVecOrVal
			local sumVec: Vector = mVec + val
			sumVectors[i] = sumVec
		end
	end
	return Matrix.new(unpack(sumVectors))
end

function Matrix:__sub(vMatVec: Matrix | Vector) --add
	local difVectors: {[number]: Vector} = {}
	for i, mVec: Vector in ipairs(rawget(self, "_vectors")) do
		local vType: string = vMatVec.Type
		local vVecOrVal: Vector | number = vMatVec[i]
		if typeof(vVecOrVal) == "table" and vType == "Matrix" then
			assert(typeof(vVecOrVal) ~= "number")
			local vVec: Vector = vVecOrVal
			local difVec: Vector = mVec + vVec
			difVectors[i] = difVec
		else
			assert(typeof(vVecOrVal) == "number")
			local val:number = vVecOrVal
			local difVec: Vector = mVec + val
			difVectors[i] = difVec
		end
	end
	return Matrix.new(unpack(difVectors))
end

function Matrix:__mul(vMatVecNum: Matrix | Vector | number) --multiply
	local result: Matrix
	if typeof(vMatVecNum) == "table" then
		assert(vMatVecNum.Type == "Matrix" or vMatVecNum.Type == "Vector")
		if vMatVecNum.Type == "Matrix" then
			local vMatrix: Matrix = vMatVecNum

			assert(self.Dimensions[1] == self.Dimensions[2], "Bad square matrix")
			assert(vMatrix.Dimensions == self.Dimensions, "Bad matrix match")
			
			local product = {}
			local vColumns: {[number]: Vector} = vMatrix:ToVectors()

			for y, row in ipairs(self:ToRows()) do
				local baseWeights = row:ToScalars()
				product[y] = product[y] or {}
				for x, _ in ipairs(baseWeights) do
					local sum = 0
					local vec: Vector = vColumns[x]
					local multWeights = vec:ToScalars()
					for i, bScal in ipairs(baseWeights) do
						sum += bScal * multWeights[i]
					end
					product[y][x] = sum
				end
				product[y] = Vector.new(unpack(product[y]))
			end
			result = Matrix.new(unpack(product)):Transpose()
		elseif vMatVecNum.Type == "Vector" then
			local vVector: Vector = vMatVecNum
			local vScals: {[number]: number} = vVector:GetScalars()
			result = {}
			for i, mVec in ipairs(rawget(self, "_vectors")) do
				local v = vScals[i]
				result[i] = 0
				for j, s in ipairs(mVec:GetScalars()) do
					result[i] += v * s
				end
			end
		end
	elseif typeof(vMatVecNum) == "number" then
		local vNum: number = vMatVecNum
		local vecs = {}
		for i, s in ipairs(rawget(self, "_vectors")) do
			vecs[i] = s * vNum
		end
		result = Matrix.new(unpack(vecs))
	else
		error("Bad value")
	end
	return result
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


function Matrix:Transpose(): Matrix
	local vectors = self:ToRows()
	return Matrix.new(unpack(vectors))
end

function Matrix:__tostring(): string
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

function Matrix.one(dimensions): Vector
	local vecs = {}
	for i=1, dimensions[1] do
		table.insert(vecs, Vector.one(dimensions[2]))
	end
	return Vector.new(unpack(vecs))
end

function Matrix.identity(dimensions): Vector
	local vecs = {}
	for i=1, dimensions[1] do
		table.insert(vecs, Vector.identity(dimensions[2], i))
	end
	return Vector.new(unpack(vecs))
end

export type Matrix = typeof(Matrix.new(Vector.new(0,0), Vector.new(0,0)))


return Matrix