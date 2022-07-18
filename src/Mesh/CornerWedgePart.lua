--!strict
local types = require(script.Parent.Parent.Types)
type Point = types.Point
type Vertex = types.Vertex
type Normal = types.Normal
type Axis = types.Axis
type Line = types.Line
type Surface = types.Surface
type Face = types.Face
type Radian = types.Radian

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
	return (part.CFrame * CFrame.new(offset * Vector3.new(-1, 1, 1))).p
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

function module.getSurfaces(cornerWedge: CornerWedgePart): { [Face]: Surface }
	local lines = module.getLines(cornerWedge)
	local opposite = cornerWedge.Size.Y

	local angle: Radian = math.atan2(opposite, cornerWedge.Size.Z)
	local angle2: Radian = math.atan2(opposite, cornerWedge.Size.X)

	local vector = {
		Top = getSurfaceCFrame(cornerWedge, Vector3.new(0, 0, 1):Lerp(Vector3.new(0, 1, 0), math.cos(angle))).LookVector,
		Bottom = getSurfaceCFrame(cornerWedge, Vector3.new(0, -1, 0)).LookVector,
		Left = getSurfaceCFrame(cornerWedge, Vector3.new(1, 0, 0)).LookVector,
		Right = getSurfaceCFrame(cornerWedge, Vector3.new(-1, 0, 0):Lerp(Vector3.new(0, 1, 0), math.cos(angle2))).LookVector,
		Back = getSurfaceCFrame(cornerWedge, Vector3.new(0, 0, -1)).LookVector,
	}
	local surfaces: { [Face]: Surface } = {}
	for k, surfaceLineKeys in pairs({
		Front = { "nBorder", "eTerrace", "wTerrace" },
		Bottom = { "sBorder", "nBorder", "eBorder", "wBorder" },
		Right = { "seColumn", "eBorder", "eTerrace" },
		Left = { "swColumn", "wBorder", "wTerrace" },
		Back = { "seColumn", "swColumn", "sBorder" },
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
