
local replicatedStorage = game:GetService("ReplicatedStorage")

local surfaceUtils = require(script.Parent:WaitForChild("SurfaceUtils"))
local draw = require(script.Parent.Parent:WaitForChild("Draw"))

function getWorldPosition(part:BasePart, offset: Vector3)
	return (part.CFrame * CFrame.new(offset*Vector3.new(1,1,-1))).p
end

local module = {}

function module.getVertices(wedge: WedgePart)
	local x = wedge.Size.X/2
	local y = wedge.Size.Y/2
	local z = wedge.Size.Z/2

	return {
		getWorldPosition(wedge, Vector3.new(x, -y, z)),
		getWorldPosition(wedge, Vector3.new(-x, -y, z)),

		getWorldPosition(wedge, Vector3.new(x, -y, -z)),
		getWorldPosition(wedge, Vector3.new(-x, -y, -z)),

		getWorldPosition(wedge, Vector3.new(x, y, -z)),
		getWorldPosition(wedge, Vector3.new(-x, y, -z)),
	}
end

function module.getLines(wedge: WedgePart)
	local x = wedge.Size.X/2
	local y = wedge.Size.Y/2
	local z = wedge.Size.Z/2

	return {
		seColumn = {
			getWorldPosition(wedge, Vector3.new(x, -y, -z)),
			getWorldPosition(wedge, Vector3.new(x, y, -z)),
		},
		swColumn = {
			getWorldPosition(wedge, Vector3.new(-x, -y, -z)),
			getWorldPosition(wedge, Vector3.new(-x, y, -z)),
		},
		nBorder = {
			getWorldPosition(wedge, Vector3.new(x, -y, z)),
			getWorldPosition(wedge, Vector3.new(-x, -y, z)),
		},
		sBorder = {
			getWorldPosition(wedge, Vector3.new(x, -y, -z)),
			getWorldPosition(wedge, Vector3.new(-x, -y, -z)),
		},
		wBorder = {
			getWorldPosition(wedge, Vector3.new(-x, -y, -z)),
			getWorldPosition(wedge, Vector3.new(-x, -y, z)),
		},
		eBorder = {
			getWorldPosition(wedge, Vector3.new(x, -y, -z)),
			getWorldPosition(wedge, Vector3.new(x, -y, z)),
		},
		sTerrace = {
			getWorldPosition(wedge, Vector3.new(x, y, -z)),
			getWorldPosition(wedge, Vector3.new(-x, y, -z)),
		},
		wTerrace = {
			getWorldPosition(wedge, Vector3.new(-x, y, -z)),
			getWorldPosition(wedge, Vector3.new(-x, -y, z)),
		},
		eTerrace = {
			getWorldPosition(wedge, Vector3.new(x, y, -z)),
			getWorldPosition(wedge, Vector3.new(x, -y, z)),
		},
	}
end

function module.getSurfaces(wedge: WedgePart)
	local lines = module.getLines(wedge)
	local surfaces = {}

	local opposite = wedge.Size.Y
	local adjacent = wedge.Size.Z
	local angle = math.atan2(opposite, adjacent)

	local vector = {
		top = surfaceUtils.getSurfaceCFrame(wedge, Vector3.new(0,0,-1):Lerp(Vector3.new(0,1,0), math.cos(angle))).LookVector,
		bottom = surfaceUtils.getSurfaceCFrame(wedge, Vector3.new(0,-1,0)).LookVector,
		west = surfaceUtils.getSurfaceCFrame(wedge, Vector3.new(-1,0,0)).LookVector,
		east = surfaceUtils.getSurfaceCFrame(wedge, Vector3.new(1,0,0)).LookVector,
		south = surfaceUtils.getSurfaceCFrame(wedge, Vector3.new(0,0,1)).LookVector,
	}

	local surfaceLines = {}
	local surfaceDirection = {}
	for k, surfaceLineKeys in pairs({
		top = {"sTerrace", "nBorder", "eTerrace", "wTerrace"},
		bottom = {"sBorder", "nBorder", "eBorder", "wBorder"},
		east = {"seColumn", "eBorder", "eTerrace"},
		west = {"swColumn", "wBorder", "wTerrace"},
		south = {"seColumn", "swColumn", "sBorder", "sTerrace"},
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
