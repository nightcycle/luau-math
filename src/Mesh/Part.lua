--!strict
local types = require(script.Parent.Parent.Types)
type Point = types.Point
type Vertex = types.Vertex
type Normal = types.Normal
type Axis = types.Axis
type Line = types.Line
type Surface = types.Surface

local normals: {[string]: Enum.NormalId} = {
	Top = Enum.NormalId.Top,
	Bottom = Enum.NormalId.Bottom,
	Back = Enum.NormalId.Back,
	Front = Enum.NormalId.Front,
	Right = Enum.NormalId.Right,
	Left = Enum.NormalId.Left,
}

function getSurfaceCFrame(part: Part, lnormal: Normal): CFrame
	local UP = Vector3.new(0, 1, 0)
	local BACK = Vector3.new(0, 0, 1)
	local EXTRASPIN = CFrame.fromEulerAnglesXYZ(math.pi / 2, 0, 0)

	local function getTranstionBetween(a: Normal, b: Normal, pitchAxis: Axis)
		local dot: number = a:Dot(b)
		if dot > 0.99999 then
			return CFrame.new()
		elseif dot < -0.99999 then
			return CFrame.fromAxisAngle(pitchAxis, math.pi)
		end
		return CFrame.fromAxisAngle(a:Cross(b), math.acos(dot))
	end

	local transition: CFrame = getTranstionBetween(UP, lnormal, BACK)
	return part.CFrame * transition * EXTRASPIN
end

function getWorldPosition(part: BasePart, offset: Vector3): Point
	return (part.CFrame * CFrame.new(offset * Vector3.new(-1, 1, 1))).Position
end

local module = {}

function module.getVertices(block: BasePart): { [number]: Vertex }
	local x = block.Size.X / 2
	local y = block.Size.Y / 2
	local z = block.Size.Z / 2

	local vertices = {
		getWorldPosition(block, Vector3.new(x, -y, z)),
		getWorldPosition(block, Vector3.new(-x, -y, z)),
		getWorldPosition(block, Vector3.new(x, y, z)),
		getWorldPosition(block, Vector3.new(-x, y, z)),
		getWorldPosition(block, Vector3.new(x, -y, -z)),
		getWorldPosition(block, Vector3.new(-x, -y, -z)),
		getWorldPosition(block, Vector3.new(x, y, -z)),
		getWorldPosition(block, Vector3.new(-x, y, -z)),
	}
	-- draw.point(vertices[1], Color3.new(1,0,0))
	-- draw.point(vertices[2], Color3.new(1,0,0))
	-- draw.point(vertices[3], Color3.new(1,0,0))
	-- draw.point(vertices[4], Color3.new(1,0,0))
	return vertices
end

function module.getLines(block: BasePart): { [string]: Line }
	local x = block.Size.X / 2
	local y = block.Size.Y / 2
	local z = block.Size.Z / 2

	local lines = {
		nwColumn = {
			getWorldPosition(block, Vector3.new(-x, -y, z)),
			getWorldPosition(block, Vector3.new(-x, y, z)),
		},
		neColumn = {
			getWorldPosition(block, Vector3.new(x, -y, z)),
			getWorldPosition(block, Vector3.new(x, y, z)),
		},
		seColumn = {
			getWorldPosition(block, Vector3.new(x, -y, -z)),
			getWorldPosition(block, Vector3.new(x, y, -z)),
		},
		swColumn = {
			getWorldPosition(block, Vector3.new(-x, -y, -z)),
			getWorldPosition(block, Vector3.new(-x, y, -z)),
		},
		nBorder = {
			getWorldPosition(block, Vector3.new(x, -y, z)),
			getWorldPosition(block, Vector3.new(-x, -y, z)),
		},
		sBorder = {
			getWorldPosition(block, Vector3.new(x, -y, -z)),
			getWorldPosition(block, Vector3.new(-x, -y, -z)),
		},
		wBorder = {
			getWorldPosition(block, Vector3.new(-x, -y, -z)),
			getWorldPosition(block, Vector3.new(-x, -y, z)),
		},
		eBorder = {
			getWorldPosition(block, Vector3.new(x, -y, -z)),
			getWorldPosition(block, Vector3.new(x, -y, z)),
		},
		sTerrace = {
			getWorldPosition(block, Vector3.new(x, y, -z)),
			getWorldPosition(block, Vector3.new(-x, y, -z)),
		},
		nTerrace = {
			getWorldPosition(block, Vector3.new(x, y, z)),
			getWorldPosition(block, Vector3.new(-x, y, z)),
		},
		wTerrace = {
			getWorldPosition(block, Vector3.new(-x, y, -z)),
			getWorldPosition(block, Vector3.new(-x, y, z)),
		},
		eTerrace = {
			getWorldPosition(block, Vector3.new(x, y, -z)),
			getWorldPosition(block, Vector3.new(x, y, z)),
		},
	}
	-- local function drawLine(line)
	-- 	draw.point(line[1], (line[2] - line[1]).Unit, Color3.new(1,1,0))
	-- end
	-- drawLine(lines.nwColumn)
	-- drawLine(lines.nTerrace)
	-- drawLine(lines.nBorder)
	-- drawLine(lines.newColumn)
	return lines
end

function module.getSurfaces(block: Part): { [Enum.NormalId]: Surface }
	local lines = module.getLines(block)

	local vector = {
		Top = getSurfaceCFrame(block, Vector3.new(0, 1, 0)).LookVector,
		Bottom = getSurfaceCFrame(block, Vector3.new(0, -1, 0)).LookVector,
		Left = getSurfaceCFrame(block, Vector3.new(-1, 0, 0)).LookVector,
		Right = getSurfaceCFrame(block, Vector3.new(1, 0, 0)).LookVector,
		Front = getSurfaceCFrame(block, Vector3.new(0, 0, 1)).LookVector,
		Back = getSurfaceCFrame(block, Vector3.new(0, 0, -1)).LookVector,
	}
	local surfaces: { [Enum.NormalId]: Surface } = {}
	for normalId: Enum.NormalId, surfaceLineKeys in pairs({
		[normals.Top] = { "sTerrace", "nTerrace", "eTerrace", "wTerrace" },
		[normals.Bottom] = { "sBorder", "nBorder", "eBorder", "wBorder" },
		[normals.Right] = { "seColumn", "neColumn", "eBorder", "eTerrace" },
		[normals.Left] = { "swColumn", "nwColumn", "wBorder", "wTerrace" },
		[normals.Front] = { "neColumn", "nwColumn", "nBorder", "nTerrace" },
		[normals.Back] = { "seColumn", "swColumn", "sBorder", "sTerrace" },
	}) do
		local surfaceSpecificLines = {}
		for i, bondKey in pairs(surfaceLineKeys) do
			table.insert(surfaceSpecificLines, lines[bondKey])
		end
		surfaces[normalId] = {
			Normal = vector[normalId],
			Lines = surfaceSpecificLines,
		} :: Surface
	end

	return surfaces
end

return module
