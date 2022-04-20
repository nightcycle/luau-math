
local replicatedStorage = game:GetService("ReplicatedStorage")

local surfaceUtils = require(script.Parent:WaitForChild("SurfaceUtils"))
local draw = require(script.Parent.Parent:WaitForChild("Draw"))
function getWorldPosition(part:BasePart, offset: Vector3)
	return (part.CFrame * CFrame.new(offset*Vector3.new(-1,1,1))).p
end

local module = {}

function module.getVertices(cornerWedge: CornerWedgePart)
	local x = cornerWedge.Size.X/2
	local y = cornerWedge.Size.Y/2
	local z = cornerWedge.Size.Z/2

	return {
		getWorldPosition(cornerWedge, Vector3.new(x, -y, z)),
		getWorldPosition(cornerWedge, Vector3.new(-x, -y, z)),
	
		getWorldPosition(cornerWedge, Vector3.new(x, -y, -z)),
		getWorldPosition(cornerWedge, Vector3.new(-x, -y, -z)),
	
		getWorldPosition(cornerWedge, Vector3.new(-x, y, -z)),
	}
end

function module.getLines(cornerWedge: CornerWedgePart)
	local x = cornerWedge.Size.X/2
	local y = cornerWedge.Size.Y/2
	local z = cornerWedge.Size.Z/2

	return {
		swColumn = {
			getWorldPosition(cornerWedge, Vector3.new(-x, -y, -z)),
			getWorldPosition(cornerWedge, Vector3.new(-x, y, -z)),
		},
		nBorder = {
			getWorldPosition(cornerWedge, Vector3.new(x, -y, z)),
			getWorldPosition(cornerWedge, Vector3.new(-x, -y, z)),
		},
		sBorder = {
			getWorldPosition(cornerWedge, Vector3.new(x, -y, -z)),
			getWorldPosition(cornerWedge, Vector3.new(-x, -y, -z)),
		},
		wBorder = {
			getWorldPosition(cornerWedge, Vector3.new(-x, -y, -z)),
			getWorldPosition(cornerWedge, Vector3.new(-x, -y, z)),
		},
		eBorder = {
			getWorldPosition(cornerWedge, Vector3.new(x, -y, -z)),
			getWorldPosition(cornerWedge, Vector3.new(x, -y, z)),
		},
		wTerrace = {
			getWorldPosition(cornerWedge, Vector3.new(-x, y, -z)),
			getWorldPosition(cornerWedge, Vector3.new(-x, -y, z)),
		},
		eTerrace = {
			getWorldPosition(cornerWedge, Vector3.new(x, -y, z)),
			getWorldPosition(cornerWedge, Vector3.new(-x, y, -z)),
		},
		seColumn = {
			getWorldPosition(cornerWedge, Vector3.new(x, -y, -z)),
			getWorldPosition(cornerWedge, Vector3.new(-x, y, -z)),
		},
	}
end

function module.getSurfaces(cornerWedge: CornerWedgePart)
	local lines = module.getLines(cornerWedge)
	local surfaces = {}
	local opposite = cornerWedge.Size.Y
	
	local angle = math.atan2(opposite, cornerWedge.Size.Z)
	local angle2 = math.atan2(opposite, cornerWedge.Size.X)

	local vector = {
		top = surfaceUtils.getSurfaceCFrame(cornerWedge, Vector3.new(0,0,1):Lerp(Vector3.new(0,1,0), math.cos(angle))).LookVector,
		bottom = surfaceUtils.getSurfaceCFrame(cornerWedge, Vector3.new(0,-1,0)).LookVector,
		west = surfaceUtils.getSurfaceCFrame(cornerWedge, Vector3.new(1,0,0)).LookVector,
		east = surfaceUtils.getSurfaceCFrame(cornerWedge, Vector3.new(-1,0,0):Lerp(Vector3.new(0,1,0), math.cos(angle2))).LookVector,
		south = surfaceUtils.getSurfaceCFrame(cornerWedge, Vector3.new(0,0,-1)).LookVector,
	}

	local surfaceLines = {}
	local surfaceDirection = {}
	for k, surfaceLineKeys in pairs({
		top = {"nBorder", "eTerrace", "wTerrace"},
		bottom = {"sBorder", "nBorder", "eBorder", "wBorder"},
		east = {"seColumn", "eBorder", "eTerrace"},
		west = {"swColumn", "wBorder", "wTerrace"},
		south = {"seColumn", "swColumn", "sBorder"},
	}) do
		local surfaceSpecificLines = {}
		for i, bondKey in pairs(surfaceLineKeys) do
			table.insert(surfaceSpecificLines, lines[bondKey])
		end
		surfaceDirection[k] = vector[k]
		surfaceLines[k] = surfaceSpecificLines
	end

	return surfaceDirection, surfaceLines
end

return module