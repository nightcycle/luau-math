
local replicatedStorage = game:GetService("ReplicatedStorage")

function getSurfaceCFrame(part, lnormal)
	local UP = Vector3.new(0, 1, 0)
	local BACK = Vector3.new(0, 0, 1)
	local EXTRASPIN = CFrame.fromEulerAnglesXYZ(math.pi/2, 0, 0)

	local function getTranstionBetween(v1, v2, pitchAxis)
		local dot = v1:Dot(v2)
		if dot > 0.99999 then
			return CFrame.new()
		elseif dot < -0.99999 then
			return CFrame.fromAxisAngle(pitchAxis, math.pi)
		end
		return CFrame.fromAxisAngle(v1:Cross(v2), math.acos(dot))
	end
	
	local transition = getTranstionBetween(UP, lnormal, BACK)
	return part.CFrame * transition * EXTRASPIN
end


function getWorldPosition(part:BasePart, offset: Vector3)
	return (part.CFrame * CFrame.new(offset*Vector3.new(1,1,1))).p
end

local module = {}

function module.getVertices(cornerWedge: CornerWedgePart)
	local x = cornerWedge.Size.X/2
	local y = cornerWedge.Size.Y/2
	local z = cornerWedge.Size.Z/2

	return {
		-- getWorldPosition(cornerWedge, Vector3.new(x, -y, z)),
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
		-- nBorder = {
		-- 	-- getWorldPosition(cornerWedge, Vector3.new(x, -y, z)),
		-- 	getWorldPosition(cornerWedge, Vector3.new(-x, -y, z)),
		-- },
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
			getWorldPosition(cornerWedge, Vector3.new(-x, -y, z)),
			-- getWorldPosition(cornerWedge, Vector3.new(x, -y, z)),
		},
		wTerrace = {
			getWorldPosition(cornerWedge, Vector3.new(-x, y, -z)),
			getWorldPosition(cornerWedge, Vector3.new(-x, -y, z)),
		},
		-- eTerrace = {
		-- 	-- getWorldPosition(cornerWedge, Vector3.new(x, -y, z)),
		-- 	getWorldPosition(cornerWedge, Vector3.new(-x, y, -z)),
		-- },
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
		top = getSurfaceCFrame(cornerWedge, Vector3.new(0,0,1):Lerp(Vector3.new(0,1,0), math.cos(angle))).LookVector,
		bottom = getSurfaceCFrame(cornerWedge, Vector3.new(0,-1,0)).LookVector,
		west = getSurfaceCFrame(cornerWedge, Vector3.new(1,0,0)).LookVector,
		east = getSurfaceCFrame(cornerWedge, Vector3.new(-1,0,0):Lerp(Vector3.new(0,1,0), math.cos(angle2))).LookVector,
		south = getSurfaceCFrame(cornerWedge, Vector3.new(0,0,-1)).LookVector,
	}

	local surfaceLines = {}
	local surfaceDirection = {}
	for k, surfaceLineKeys in pairs({
		top = {"eBorder", "eTerrace", "wTerrace"}, --front
		bottom = {"sBorder", "eBorder", "wBorder"}, --bottom
		-- east = {"seColumn", "eBorder", "eTerrace"},
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