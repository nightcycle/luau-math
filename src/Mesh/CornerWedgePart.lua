--!strict
local types = require(script.Parent.Parent.Types)
type Point = types.Point
type Vertex = types.Vertex
type Normal = types.Normal
type Axis = types.Axis
type Line = types.Line
type Surface = types.Surface
type Radian = types.Radian

local normals: {[string]: Enum.NormalId} = {
	Top = Enum.NormalId.Top,
	Bottom = Enum.NormalId.Bottom,
	Back = Enum.NormalId.Back,
	Front = Enum.NormalId.Front,
	Right = Enum.NormalId.Right,
	Left = Enum.NormalId.Left,
}

function getSurfaceCFrame(part: CornerWedgePart, lnormal: Normal): CFrame
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

function module.getVertices(cornerWedge: CornerWedgePart): { [number]: Vertex }
	local x = cornerWedge.Size.X / 2
	local y = cornerWedge.Size.Y / 2
	local z = cornerWedge.Size.Z / 2

	return {
		getWorldPosition(cornerWedge, Vector3.new(x, -y, z)),
		getWorldPosition(cornerWedge, Vector3.new(-x, -y, z)),

		getWorldPosition(cornerWedge, Vector3.new(x, -y, -z)),
		getWorldPosition(cornerWedge, Vector3.new(-x, -y, -z)),

		getWorldPosition(cornerWedge, Vector3.new(-x, y, -z)),
	}
end

function module.getLines(cornerWedge: CornerWedgePart): { [string]: Line }
	local x = cornerWedge.Size.X / 2
	local y = cornerWedge.Size.Y / 2
	local z = cornerWedge.Size.Z / 2

	return {
		swColumn = {
			getWorldPosition(cornerWedge, Vector3.new(-x, -y, -z)),
			getWorldPosition(cornerWedge, Vector3.new(-x, y, -z)),
		} :: Line,
		nBorder = {
			getWorldPosition(cornerWedge, Vector3.new(x, -y, z)),
			getWorldPosition(cornerWedge, Vector3.new(-x, -y, z)),
		} :: Line,
		sBorder = {
			getWorldPosition(cornerWedge, Vector3.new(x, -y, -z)),
			getWorldPosition(cornerWedge, Vector3.new(-x, -y, -z)),
		} :: Line,
		wBorder = {
			getWorldPosition(cornerWedge, Vector3.new(-x, -y, -z)),
			getWorldPosition(cornerWedge, Vector3.new(-x, -y, z)),
		} :: Line,
		eBorder = {
			getWorldPosition(cornerWedge, Vector3.new(x, -y, -z)),
			getWorldPosition(cornerWedge, Vector3.new(x, -y, z)),
		} :: Line,
		wTerrace = {
			getWorldPosition(cornerWedge, Vector3.new(-x, y, -z)),
			getWorldPosition(cornerWedge, Vector3.new(-x, -y, z)),
		},
		eTerrace = {
			getWorldPosition(cornerWedge, Vector3.new(x, -y, z)),
			getWorldPosition(cornerWedge, Vector3.new(-x, y, -z)),
		} :: Line,
		seColumn = {
			getWorldPosition(cornerWedge, Vector3.new(x, -y, -z)),
			getWorldPosition(cornerWedge, Vector3.new(-x, y, -z)),
		} :: Line,
	}
end

function module.getSurfaces(cornerWedge: CornerWedgePart): { [Enum.NormalId]: Surface }
	local lines = module.getLines(cornerWedge)
	local opposite = cornerWedge.Size.Y

	local angle: Radian = math.atan2(opposite, cornerWedge.Size.Z)
	local angle2: Radian = math.atan2(opposite, cornerWedge.Size.X)

	local vector = {
		[Enum.NormalId.Top] = getSurfaceCFrame(cornerWedge, Vector3.new(0, 0, 1):Lerp(Vector3.new(0, 1, 0), math.cos(angle))).LookVector,
		[Enum.NormalId.Bottom] = getSurfaceCFrame(cornerWedge, Vector3.new(0, -1, 0)).LookVector,
		[Enum.NormalId.Left] = getSurfaceCFrame(cornerWedge, Vector3.new(1, 0, 0)).LookVector,
		[Enum.NormalId.Right] = getSurfaceCFrame(cornerWedge, Vector3.new(-1, 0, 0):Lerp(Vector3.new(0, 1, 0), math.cos(angle2))).LookVector,
		[Enum.NormalId.Back] = getSurfaceCFrame(cornerWedge, Vector3.new(0, 0, -1)).LookVector,
	}
	local surfaces: {[Enum.NormalId]: Surface } = {}
	for normalId, surfaceLineKeys in pairs({
		[normals.Front] = { "nBorder", "eTerrace", "wTerrace" },
		[normals.Bottom] = { "sBorder", "nBorder", "eBorder", "wBorder"},
		[normals.Right] = { "seColumn", "eBorder", "eTerrace" },
		[normals.Left] = { "swColumn", "wBorder", "wTerrace" },
		[normals.Back] = { "seColumn", "swColumn", "sBorder" },
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
