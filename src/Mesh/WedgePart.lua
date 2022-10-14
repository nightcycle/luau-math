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

function getSurfaceCFrame(part: BasePart, lnormal: Normal): CFrame
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

function module.getVertices(wedge: BasePart): { [number]: Vertex }
	local x = wedge.Size.X / 2
	local y = wedge.Size.Y / 2
	local z = wedge.Size.Z / 2

	return {
		getWorldPosition(wedge, Vector3.new(x, -y, z)),
		getWorldPosition(wedge, Vector3.new(-x, -y, z)),

		getWorldPosition(wedge, Vector3.new(x, -y, -z)),
		getWorldPosition(wedge, Vector3.new(-x, -y, -z)),

		getWorldPosition(wedge, Vector3.new(x, y, -z)),
		getWorldPosition(wedge, Vector3.new(-x, y, -z)),
	}
end

function module.getLines(wedge: BasePart): { [string]: Line }
	local x = wedge.Size.X / 2
	local y = wedge.Size.Y / 2
	local z = wedge.Size.Z / 2

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

function module.getSurfaces(wedge: BasePart): { [Enum.NormalId]: Surface }
	local lines = module.getLines(wedge)

	local opposite = wedge.Size.Y
	local adjacent = wedge.Size.Z
	local angle = math.atan2(opposite, adjacent)

	local vector = {
		[normals.Top] = getSurfaceCFrame(wedge, Vector3.new(0, 0, -1):Lerp(Vector3.new(0, 1, 0), math.cos(angle))).LookVector,
		[normals.Bottom] = getSurfaceCFrame(wedge, Vector3.new(0, -1, 0)).LookVector,
		[normals.Left] = getSurfaceCFrame(wedge, Vector3.new(-1, 0, 0)).LookVector,
		[normals.Right] = getSurfaceCFrame(wedge, Vector3.new(1, 0, 0)).LookVector,
		[normals.Back] = getSurfaceCFrame(wedge, Vector3.new(0, 0, 1)).LookVector,
	}

	local surfaces: { [Enum.NormalId]: Surface } = {}

	for k, surfaceLineKeys in pairs({
		[normals.Top] = { "sTerrace", "nBorder", "eTerrace", "wTerrace" },
		[normals.Bottom] = { "sBorder", "nBorder", "eBorder", "wBorder" },
		[normals.Right] = { "seColumn", "eBorder", "eTerrace" },
		[normals.Left] = { "swColumn", "wBorder", "wTerrace" },
		[normals.Back] = { "seColumn", "swColumn", "sBorder", "sTerrace" },
	}) do
		local surfaceSpecificLines = {}
		for i, bondKey in pairs(surfaceLineKeys) do
			table.insert(surfaceSpecificLines, lines[bondKey])
		end
		surfaces[k] = {
			Normal = vector[k],
			Lines = surfaceSpecificLines,
		} :: Surface
	end

	return surfaces
end

return module
