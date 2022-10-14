--!strict
local types = require(script.Parent.Types)
type Point = types.Point
type Vertex = types.Vertex
type Normal = types.Normal
type Axis = types.Axis
type Line = types.Line
type Surface = types.Surface

local PartSolver = require(script:WaitForChild("Part"))
local WedgePartSolver = require(script:WaitForChild("WedgePart"))
local TetraPartSolver = require(script:WaitForChild("TetraPart"))
local CornerWedgePartSolver = require(script:WaitForChild("CornerWedgePart"))

--- @class Mesh
--- A basic utility for translating meshes into geometry useful elements. Does not currently support CSG or most user-imported meshes.

local Mesh = {}
Mesh.__index = Mesh

--- @prop TetraPartAssetId number
--- @within Mesh
--- this is the id for the free model tetrahedron meshpart I use

Mesh.TetraPartAssetId = 552212360

function getSolver(basePart: BasePart): (BasePart) -> any | nil
	local result: any
	if basePart:IsA("CornerWedgePart") then
		result = CornerWedgePartSolver
	elseif basePart:IsA("WedgePart") then
		result = WedgePartSolver
	elseif basePart:IsA("MeshPart") and basePart.MeshId == "rbxassetid://"..tostring(Mesh.TetraPartAssetId) then
		result = TetraPartSolver
	elseif basePart:IsA("BasePart") then
		result = PartSolver
	end
	return result
end

--- provides a list of vertex positions in 3d space
function Mesh.getVertices(basePart: BasePart): { [number]: Vertex }
	local solver: any = getSolver(basePart)
	return solver.getVertices(basePart)
end

--- provides a dictionary of line vertex pairs
function Mesh.getLines(basePart: BasePart): { [string]: Line }
	local solver: any = getSolver(basePart)
	return solver.getLines(basePart)
end

--- provides a dictionary of surface geometry data
function Mesh.getSurfaces(basePart: BasePart): {[Enum.NormalId]: Surface}
	local solver: any = getSolver(basePart)
	return solver.getSurfaces(basePart)
end

--- returns two wedgeparts created to fit on all three points. 
function Mesh.renderTriangle(a: Point, b: Point, c: Point, thickness: number): (WedgePart, WedgePart)
	thickness = thickness or 0
	
	local w1 = Instance.new("WedgePart")
	w1.Anchored = true
	w1.TopSurface = Enum.SurfaceType.Smooth
	w1.BottomSurface = Enum.SurfaceType.Smooth
	local w2 = w1:Clone()
	
	-- Render the 3D triangle
	local ab, ac, bc = b - a, c - a, c - b
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
	
	if (abd > acd and abd > bcd) then
		c, a = a, c
	elseif (acd > bcd and acd > abd) then
		a, b = b, a
	end
	
	ab, ac, bc = b - a, c - a, c - b
	
	local right = ac:Cross(ab).Unit
	local up = bc:Cross(right).Unit
	local back = bc.Unit
	
	local height = math.abs(ab:Dot(up))
	
	w1.Size = Vector3.new(thickness, height, math.abs(ab:Dot(back)))
	w1.CFrame = CFrame.fromMatrix((a + b)/2, right, up, back)

	w2.Size = Vector3.new(thickness, height, math.abs(ac:Dot(back)))
	w2.CFrame = CFrame.fromMatrix((a + c)/2, -right, up, -back)

	return w1, w2
end

--- Performs a greedy mesh style simplification on a 3d table of boolean values
function Mesh.solveGreedyMesh(grid: { [Vector3]: boolean })
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

			while tryX(xMax + 1) do
				xMax += 1
			end
			local xMin = c3.X
			while tryX(xMin - 1) do
				xMin -= 1
			end

			--get y range
			local function tryXY(newY)
				for x = xMin, xMax do
					local newC3 = Vector3.new(x, newY, c3.Z)
					if not try(newC3) then
						return false
					end
				end
				return true
			end
			local yMax = c3.Y
			while tryXY(yMax + 1) do
				yMax += 1
			end
			local yMin = c3.Y
			while tryXY(yMin - 1) do
				yMin -= 1
			end

			--get z range
			local function tryXYZ(newZ)
				for x = xMin, xMax do
					for y = yMin, yMax do
						local newC3 = Vector3.new(x, y, newZ)
						if not try(newC3) then
							return false
						end
					end
				end
				return true
			end
			local zMax = c3.Z
			while tryXYZ(zMax + 1) do
				zMax += 1
			end
			local zMin = c3.Z
			while tryXYZ(zMin - 1) do
				zMin -= 1
			end

			--create region
			table.insert(regions, { Vector3.new(xMin, yMin, zMin), Vector3.new(xMax, yMax, zMax) })
			for x = xMin, xMax do
				for y = yMin, yMax do
					for z = zMin, zMax do
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

--- Generates a smallish bounding box at cframe that contains all the parts without the need for a model. 
function Mesh.getBoundingBoxAtCFrame(orientation: CFrame, parts: { [number]: BasePart })
	-- print("A")
	if #parts == 0 then
		return Vector3.new(0, 0, 0), CFrame.new(0, 0, 0)
	end
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
			vertices[(orientation:Inverse() * CFrame.new(v3)).Position] = true
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

	local centerCF = orientation
		* CFrame.fromMatrix(minV3:Lerp(maxV3, 0.5), orientation.XVector, orientation.YVector, orientation.ZVector)
	local size = maxV3 - minV3
	return size, centerCF
end

return Mesh
