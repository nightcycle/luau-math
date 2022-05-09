local Mesh = {}

local BasePartSolver = require(script:WaitForChild("BasePart"))
local WedgePartSolver = require(script:WaitForChild("WedgePart"))
local TetraPartSolver = require(script:WaitForChild("TetraPart"))
local CornerWedgePartSolver = require(script:WaitForChild("CornerWedgePart"))

function getSolver(basePart: BasePart)
	if basePart:IsA("CornerWedgePart") then
		return CornerWedgePartSolver
	elseif basePart:IsA("WedgePart") then
		return WedgePartSolver
	elseif basePart:IsA("MeshPart") and basePart.MeshId == "rbxassetid://552212360" then
		return TetraPartSolver
	elseif basePart:IsA("BasePart") then
		return BasePartSolver
	end
end

function Mesh.getVertices(basePart: BasePart)
	local solver = getSolver(basePart)
	return solver.getVertices(basePart)
end

function Mesh.getLines(basePart: BasePart)
	local solver = getSolver(basePart)
	return solver.getLines(basePart)
end

function Mesh.getSurfaces(basePart: BasePart)
	local solver = getSolver(basePart)
	return solver.getSurfaces(basePart)
end


function Mesh.solveGreedyMesh(grid: {[Vector3]: boolean})
	-- print("Grid", grid)
	local registry = {}
	local regions = {}
	for c3, _ in pairs(grid) do
		-- print("C3", c3)
		if registry[c3] == nil then
			-- print("No registry entry")
			local function try(newC3)
				if grid[newC3] ~= nil and registry[newC3] == nil then
					return true
				else
					return false
				end
			end

			--get x range
			local function tryX(newX)
				local newC3 = Vector3.new(newX, c3.Y, c3.Z)
				return try(newC3)
			end
			local xMax = c3.X
			
			while tryX(xMax+1) do
				xMax += 1
			end
			local xMin = c3.X
			while tryX(xMin-1) do
				xMin -= 1
			end
			
			--get y range
			local function tryXY(newY)
				for x=xMin, xMax do
					local newC3 = Vector3.new(x, newY, c3.Z)
					if not try(newC3) then
						return false
					end
				end
				return true
			end
			local yMax = c3.Y
			while tryXY(yMax+1) do
				yMax += 1
			end
			local yMin = c3.Y
			while tryXY(yMin-1) do
				yMin -= 1
			end

			--get z range
			local function tryXYZ(newZ)
				for x=xMin, xMax do
					for y=yMin, yMax do
						local newC3 = Vector3.new(x, y, newZ)
						if not try(newC3) then
							return false
						end
					end
				end
				return true
			end
			local zMax = c3.Z
			while tryXYZ(zMax+1) do
				zMax += 1
			end
			local zMin = c3.Z
			while tryXYZ(zMin-1) do
				zMin -= 1
			end

			--create region
			table.insert(regions, {Vector3.new(xMin, yMin, zMin), Vector3.new(xMax, yMax, zMax)})
			for x=xMin, xMax do
				for y=yMin, yMax do
					for z=zMin, zMax do
						registry[Vector3.new(x, y, z)] = #regions
					end
				end
			end
		-- else
			-- print("Already incorporated")
		end
	end

	return regions
end

function Mesh.getBoundingBoxAtCFrame(orientation: CFrame, parts: {[number]: BasePart})
	-- print("A")
	if #parts == 0 then return Vector3.new(0,0,0), CFrame.new(0,0,0) end
	-- print("B")
	local minX = math.huge
	local minY = math.huge
	local minZ = math.huge

	local maxX = -math.huge
	local maxY = -math.huge
	local maxZ = -math.huge

	local vertices = {}
	for i, part in ipairs(parts) do
		local partVertices = Mesh.getVertices(part)
		for j, v3 in ipairs(partVertices) do
			vertices[(orientation:Inverse() * CFrame.new(v3)).p] = true
		end
	end
	-- print(vertices)
	for v3, _ in pairs(vertices) do
		minX = math.min(v3.X, minX)
		minY = math.min(v3.Y, minY)
		minZ = math.min(v3.Z, minZ)
		maxX = math.max(v3.X, maxX)
		maxY = math.max(v3.Y, maxY)
		maxZ = math.max(v3.Z, maxZ)
	end

	local minV3 = Vector3.new(minX, minY, minZ)
	local maxV3 = Vector3.new(maxX, maxY, maxZ)
	-- print("Min", minV3, "Max", maxV3)

	local centerCF = orientation * CFrame.fromMatrix(minV3:Lerp(maxV3, 0.5), orientation.XVector, orientation.YVector, orientation.ZVector)
	local size = maxV3 - minV3
	return size, centerCF
end

function Mesh.getBoundingBox(parts: {[number]: BasePart}, worldCF: CFrame | nil)
	worldCF = worldCF or CFrame.new(0,0,0)
	local minX
	local minY
	local minZ
	local maxX
	local maxY
	local maxZ
	for i, part in ipairs(parts) do
		if part:IsA("BasePart") then
			local offsetCF = worldCF:Inverse() * part.CFrame
			local maxCorner = offsetCF * CFrame.new(part.Size*0.5).p
			local minCorner = offsetCF * CFrame.new(-part.Size*0.5).p
			local x1 = minCorner.X
			-- sort(minX, maxX, x1)
			if not minX or minX > x1 then
				minX = x1
			end
			if not maxX or maxX < x1 then
				maxX = x1
			end
			local x2 = maxCorner.X
			if not minX or minX > x2 then
				minX = x2
			end
			if not maxX or maxX < x2 then
				maxX = x2
			end
			-- sort(minX, maxX, x2)
			local y1 = minCorner.Y
			if not minY or minY > y1 then
				minY = y1
			end
			if not maxY or maxY < y1 then
				maxY = y1
			end
			-- sort(minY, maxY, y1)
			local y2 = maxCorner.Y
			if not minY or minY > y2 then
				minY = y2
			end
			if not maxY or maxY < y2 then
				maxY = y2
			end
			-- sort(minY, maxY, y2)
			local z1 = minCorner.Z
			if not minZ or minZ > z1 then
				minZ = z1
			end
			if not maxZ or maxZ < z1 then
				maxZ = z1
			end
			-- sort(minZ, maxZ, z1)
			local z2 = maxCorner.Z
			if not minZ or minZ > z2 then
				minZ = z2
			end
			if not maxZ or maxZ < z2 then
				maxZ = z2
			end
			-- sort(minZ, maxZ, z2)
			-- print("X", x1, x2, "Y", y1,y2, "Z", z1,z2)
		end
	end
	local minV3 = Vector3.new(minX, minY, minZ)
	local maxV3 = Vector3.new(maxX, maxY, maxZ)
	-- print("Min", minV3, "Max", maxV3)
	local size = maxV3 - minV3
	local center = minV3 + size*0.5
	local cf = CFrame.fromMatrix((worldCF*CFrame.new(center)).p,
		worldCF.XVector,
		worldCF.YVector,
		worldCF.ZVector
	)
	return cf, size
end

return Mesh