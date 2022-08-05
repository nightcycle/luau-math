--!strict
function deduplicateList(list: { [number]: any }): { [number]: any }
	local registry = {}
	for i, v in ipairs(list) do
		if registry[v] == nil then
			registry[v] = i
		end
	end
	local finalList = {}
	for v, i in pairs(registry) do
		table.insert(finalList, v)
	end
	return finalList
end

local types = require(script.Parent.Types)
export type Point = types.Point
export type Vertex = types.Vertex
export type Normal = types.Normal
export type Axis = types.Axis
export type Direction = types.Direction
export type Line = types.Line
export type Radian = types.Radian
export type PerimeterSequence<V> = types.PerimeterSequence<V>

local Earcut = require(script.Earcut)

--- @class Geometry
--- A long list of geometry related functions. Consider rounding your vectors to the nearest hundredth as the smallest difference can fail an equality test.
local Geometry = {}

Geometry.__index = Geometry

Geometry.phi = (1 + 5^0.5)/2


--- @prop phi number
--- @within Geometry
--- It's a constant, no need to keep resolving for it.


--- Gets length of line.
function Geometry.getLineLength(line: Line): number
	return (line[1] - line[2]).Magnitude
end

--- Performs getLineLength on a list of lines.
function Geometry.getLineLengths(lines: { [any]: Line }): { [any]: number }
	local lineLengths = {}
	for k, line in pairs(lines) do
		lineLengths[k] = Geometry.getLineLength(line)
	end
	return lineLengths
end

--- Gets a point at center of line.
function Geometry.getLineCenter(line: Line): Point
	return line[1]:Lerp(line[2], 0.5)
end

--- Performs getLineCenter on a list of lines.
function Geometry.getLineCenters(lines: { [any]: Line }): { [any]: Point }
	local lineCenters = {} :: { [any]: Point }
	for k, line in pairs(lines) do
		lineCenters[k] = Geometry.getLineCenter(line)
	end
	return lineCenters
end

--- Gets the axis running parallel to the line.
function Geometry.getLineAxis(line: Line): Axis
	return (line[1] - line[2]).Unit
end

--- Performs getLineAxis on a list of lines.
function Geometry.getLineAxes(lines: { [string]: Line }): { [string]: Axis }
	local lineAxes = {}
	for k, line in pairs(lines) do
		lineAxes[k] = Geometry.getLineAxis(line)
	end
	return lineAxes
end

--- Finds if two verticies share a line from a list of lines.
function Geometry.getIfVerticesConnected(a: Vertex, b: Vertex, lines: { [any]: Line }): boolean
	for k, line in pairs(lines) do
		if (line[1] == a and line[2] == b) or (line[1] == b and line[2] == a) then
			return true
		end
	end
	return false
end

--- Filters out any lines that don't connect to the main vertex.
function Geometry.getConnectedVertices(vertex: Vertex, lines: { [any]: Line }): { [number]: Vertex }
	local connections = {}
	for k, line in pairs(lines) do
		if vertex == line[1] then
			table.insert(connections, line[2])
		elseif vertex == line[2] then
			table.insert(connections, line[1])
		end
	end
	return connections
end

--- Compiles a deduplicated list of every unique vertex in a list of lines.
function Geometry.getAllVerticesFromLines(lines: { [string]: Line }): { [number]: Vertex }
	local vertices = {}
	for k, line in pairs(lines) do
		table.insert(vertices, line[1])
		table.insert(vertices, line[2])
	end
	return deduplicateList(vertices)
end

--- Creates an indexable dictionary of the vertices each vertex is connected to.
function Geometry.getAllVertexConnectionsFromLines(lines: { [string]: Line }): { [Vertex]: { [number]: Vertex } }
	local connectedVertexRegistry: { [Vertex]: { [Vertex]: boolean } } = {}
	for k, line in pairs(lines) do
		connectedVertexRegistry[line[1]] = connectedVertexRegistry[line[1]] or {}
		connectedVertexRegistry[line[1]][line[2]] = true
		connectedVertexRegistry[line[2]] = connectedVertexRegistry[line[2]] or {}
		connectedVertexRegistry[line[2]][line[1]] = true
	end
	local connectedVertices = {}
	for v: Vertex, registry: { [Vertex]: boolean } in pairs(connectedVertexRegistry) do
		local list = {}
		for connection: Vertex, _ in pairs(registry) do
			table.insert(list, connection)
		end
		connectedVertices[v] = list
	end
	return connectedVertices
end

--- Gets if two lins share a vertex.
function Geometry.getSharedVertex(line1: Line, line2: Line): Vertex?
	local result: Vector3?
	for i, a in ipairs(line1) do
		for j, b in ipairs(line2) do
			if a == b then
				result = a
				break
			end
		end
	end
	return result
end

--- Finds if the two lines make a right angle at the vertex
function Geometry.getIfRightAngle(vertex: Vertex, line1: Line, line2: Line): boolean
	local connectedVertices = Geometry.getConnectedVertices(vertex, { line1, line2 })
	local norm1: Normal = (vertex - connectedVertices[1]).Unit
	local norm2: Normal = (vertex - connectedVertices[2]).Unit
	local dot = norm1:Dot(norm2)
	return math.round(dot * 100) / 100 == 0
end

--- Finds if a set of vertices make a right angle.
function Geometry.getIfRightAngleFromVertices(sharedVertex: Vertex, a: Vertex, b: Vertex): boolean
	local line1: Line = { sharedVertex, a }
	local line2: Line = { sharedVertex, b }
	return Geometry.getIfRightAngle(sharedVertex, line1, line2)
end

--- Gets a point at center of line.
function Geometry.getRightAngleVertices(lines: { [string]: Line }): { [number]: Vertex }
	local connectedVertices = Geometry.getAllVertexConnectionsFromLines(lines)
	local rightAngles = {}
	for v, connections in pairs(connectedVertices) do
		local a: Vertex = connections[1]
		local b: Vertex = connections[2]
		if Geometry.getIfRightAngleFromVertices(v, a, b) then
			table.insert(rightAngles, v)
		end
	end
	return rightAngles
end

--- Gets the point of intersection between two lines, lerping between the closest points if none exist.
function Geometry.getIntersectionBetweenTwoLines(line1: Line, line2: Line): Point?
	local p1: types.Point? = Geometry.getClosestPointToLineOnLine(line1, line2)
	if not p1 then
		return
	end
	local p2: types.Point? = Geometry.getClosestPointToLineOnLine(line2, line1)
	if not p2 then
		return
	end

	assert(p1 ~= nil and p2 ~= nil)

	return p1:Lerp(p2, 0.5)
end

--- When provided a quadrangular or triangular surface's lines it will return an indexable dictionary of the point on the lins opposite a vertex, rounding to the nearest vertex if an even number of vertices.
function Geometry.getVertexOppositePointsFromLines(lines: { [any]: Line }): { [Vertex]: Point }
	local corners: { [number]: Vertex } = Geometry.getRightAngleVertices(lines)
	local vertices: { [number]: Vertex } = Geometry.getAllVerticesFromLines(lines)
	local oppositeRegistry = {}
	if #corners == 4 then --rectangle
		for i, v in ipairs(corners) do
			if oppositeRegistry[v] == nil then
				for j, opp in ipairs(corners) do
					if opp ~= v then
						if Geometry.getIfVerticesConnected(v, opp, lines) == false then
							oppositeRegistry[v] = opp
							oppositeRegistry[opp] = v
						end
					end
				end
			end
		end
	elseif #corners == 1 then --right triangle
		local corner = corners[1]
		local a = if vertices[1] == corner then vertices[2] else vertices[1]
		local b = if vertices[3] == corner then vertices[2] else vertices[3]
		local antiCorner = a:Lerp(b, 0.5)
		oppositeRegistry[corner] = antiCorner
		oppositeRegistry[a] = corner:Lerp(b, 0.5)
		oppositeRegistry[b] = corner:Lerp(a, 0.5)
	elseif #corners == 0 then --triangle
		local a = vertices[1]
		local b = vertices[3]
		local c = vertices[2]
		oppositeRegistry[a] = b:Lerp(c, 0.5)
		oppositeRegistry[b] = a:Lerp(c, 0.5)
		oppositeRegistry[c] = b:Lerp(a, 0.5)
	end

	return oppositeRegistry
end

--- Creates a list of lines connecting opposite points on any quadrangle or triangle. 
function Geometry.getDiagonalLinesFromEdges(lines: { [any]: Line }): { [number]: Line }
	local opposites: { [Vertex]: Point } = Geometry.getVertexOppositePointsFromLines(lines)

	local diagonalRegistry: { [Vertex]: Line } = {}
	for a, b in pairs(opposites) do
		if not diagonalRegistry[a] and not diagonalRegistry[b] then
			diagonalRegistry[a] = { a, b } :: Line
		end
	end

	local diagonals: { [number]: Line } = {}
	for _, line in pairs(diagonalRegistry) do
		table.insert(diagonals, line)
	end

	return diagonals
end

--- Gets the perimeter of a triangle from its vertices
function Geometry.getTrianglePerimeter(a: Vertex, b: Vertex, c: Vertex): number
	local ab: number = (a - b).Magnitude
	local bc: number = (b - c).Magnitude
	local ca: number = (c - a).Magnitude
	return ab + bc + ca
end

--- Gets the area of a triangle from its vertices
function Geometry.getTriangleArea(a: Vertex, b: Vertex, c: Vertex): number --heron's formula
	local perimeter: number = Geometry.getTrianglePerimeter(a, b, c)
	local semiPerimeterLength: number = perimeter / 2

	local aLength: number = (a - b).Magnitude
	local bLength: number = (b - c).Magnitude
	local cLength: number = (c - a).Magnitude

	local deltaA: number = (semiPerimeterLength - aLength)
	local deltaB: number = (semiPerimeterLength - bLength)
	local deltaC: number = (semiPerimeterLength - cLength)

	return math.sqrt(semiPerimeterLength * deltaA * deltaB * deltaC)
end

--- gets if a point parallel to the surface of the triangle exists within the perimeter. All unparallel points will return false.
function Geometry.getIfPointIsInTriangle(point: Point, a: Vertex, b: Vertex, c: Vertex): boolean
	local abc = Geometry.getTriangleArea(a, b, c)
	local pbc = Geometry.getTriangleArea(point, b, c)
	local abp = Geometry.getTriangleArea(a, b, point)
	return abc == pbc + abc + abp
end

--- gets the angle of vertex B when provided three lines composing a triangle.
function Geometry.getAngleThroughLawOfCos(ab: Line, bc: Line, ca: Line): Radian
	local abLen = Geometry.getLineLength(ab)
	local bcLen = Geometry.getLineLength(bc)
	local caLen = Geometry.getLineLength(ca)
	if math.round(1000 * (abLen + bcLen)) == math.round(1000 * caLen) then
		return 0
	end
	-- print("A", a, "B", b, "C", c)
	local numerator = (abLen ^ 2) + (bcLen ^ 2) - (caLen ^ 2)
	local denominator = (2 * abLen * bcLen)
	local frac = numerator / denominator
	local angle = math.acos(frac)

	return angle
end

--- Converts each line into a normal then finds the angle of both normals when they're set to the same origin.
function Geometry.getAngleBetweenTwoLines(line1: Line, line2: Line): Radian
	local corner = Geometry.getSharedVertex(line1, line2)
	local line3 = {
		if line1[1] == corner then line1[2] else line1[1],
		if line2[1] == corner then line2[2] else line2[1],
	}
	return Geometry.getAngleThroughLawOfCos(line1, line2, line3)
end

--- Gets the side length CA using an the angle of vertex B
function Geometry.getSideLengthThroughLawOfCos(b: Radian, ab: Line, bc: Line): number
	local abLen: number = Geometry.getLineLength(ab)
	local bcLen: number = Geometry.getLineLength(bc)
	return math.sqrt((abLen ^ 2) + (bcLen ^ 2) - (2 * abLen * bcLen * math.cos(b)))
end

--- Finds a normal perpindicular to the line that faces inwards and is parallel to the surface.
function Geometry.getLineInwardNormal(
	line: Line,
	centerPoint: Vector3
): Normal --does not just aim towards center point, only works on concave shapes
	local lineCenter: Point = Geometry.getLineCenter(line)
	local lV: Normal = (line[2] - line[1]).Unit
	local normalToCenter: Normal = (lineCenter - centerPoint).Unit
	local uV: Normal = lV:Cross(normalToCenter)
	local rV: Normal = uV:Cross(lV)
	local dot: number = rV:Dot(normalToCenter)
	if dot > 0 then
		return rV
	else
		return -rV
	end
end

--- Finds point in list closest to provided point.
function Geometry.getClosestPointInList(point: Point, list: { [number]: Point }): Point
	local closestPoint
	local closestDist = math.huge
	for i, v3 in ipairs(list) do
		local dist = (point - v3).Magnitude
		if dist < closestDist then
			closestDist = dist
			closestPoint = v3
		end
	end
	return closestPoint
end

--- Finds point in list farthest to provided point
function Geometry.getFarthestPointInList(point: Point, list: { [number]: Point }): Point
	local farthestPoint
	local farthestDist = 0
	for i, v3 in ipairs(list) do
		local dist = (point - v3).Magnitude
		if dist > farthestDist then
			farthestDist = dist
			farthestPoint = v3
		end
	end
	return farthestPoint
end

--- Finds the closest point on the line to the provided point.
function Geometry.getClosestPointOnLine(point: Point, line: Line)
	local start: Vertex = line[1]
	local fin: Vertex = line[2]

	local angleS: Radian = Geometry.getAngleThroughLawOfCos({ point, start }, line, { point, fin })

	local adjDist: number = math.min(math.cos(angleS) * (point - start).Magnitude, (start - fin).Magnitude)

	return start + (fin - start).Unit * adjDist
end

--- Finds the line that comes closest to the point. Chooses arbitrarily when lines are equidistant.
function Geometry.getLineClosestToPoint(point: Point, lines: { [any]: Line }): Line
	local closestLine
	local closestDist = math.huge
	for k, line in pairs(lines) do
		local closestPoint = Geometry.getClosestPointOnLine(point, line)
		local dist = (closestPoint - point).Magnitude
		if closestDist > dist then
			closestDist = dist
			closestLine = line
		end
	end
	return closestLine
end

--- Gets a point at the center of a quadrangular or triangular surface when provides its lines. 
function Geometry.getCenterFromLines(lines: { [any]: Line }): Point?
	local diagonals: { [number]: Line } = Geometry.getDiagonalLinesFromEdges(lines)
	local result: Point?
	if #lines == 4 then
		result = Geometry.getLineCenter(diagonals[1])
	elseif #lines == 3 then
		local vertices = Geometry.getAllVerticesFromLines(lines)
		local corners = Geometry.getRightAngleVertices(lines)
		if #corners == 1 then
			local diagonal1: Line = diagonals[1]
			local diagonal2: Line = diagonals[2]
			assert(diagonal1 ~= nil, "Bad diagonal 1")
			assert(diagonal2 ~= nil, "Bad diagonal 2")
			result = Geometry.getIntersectionBetweenTwoLines(diagonal1, diagonal2)
		else
			local a = vertices[1]
			local b = vertices[3]
			local c = vertices[2]
			local ab = a:Lerp(b, 0.5)
			result = ab:Lerp(c, 0.66)
		end
	end
	return result
end

--- Returns a cframe with the YVec parallel to the surface and the XVec perpindicular to the longest line.
function Geometry.getSurfaceCFrameFromLines(lines: { [any]: Line }, normal: Normal): CFrame
	local longestLine: Line = nil
	local longestLength: number = 0
	for i, line in pairs(lines) do
		local length = Geometry.getLineLength(line)
		if longestLength < length then
			longestLength = length
			longestLine = line
		end
	end

	local centerPoint: Point? = Geometry.getCenterFromLines(lines)
	assert(centerPoint ~= nil, "Bad center point")
	local lineInwardNormal: Normal = Geometry.getLineInwardNormal(longestLine, centerPoint)

	local zVec: Normal = -lineInwardNormal
	local yVec: Normal = normal
	local xVec: Normal = zVec:Cross(yVec)

	return CFrame.fromMatrix(centerPoint, xVec, yVec, zVec)
end

--- Finds the min and max points on a rotated box. Min / Max status are found in object space, not global space.
function Geometry.getBoxBoundaries(cf: CFrame, size: Vector3): (Point, Point)
	local half = size * 0.5
	local min: Point = (cf * CFrame.new(-half.X, -half.Y, -half.Z)).Position
	local max: Point = (cf * CFrame.new(half.X, half.Y, half.Z)).Position
	return min, max
end

--- Finds intersection point and distance on a plane where normal hits plane from origin. If parallel it returns the origin the normal solves from.
function Geometry.getPlaneIntersection(
	origin: Point,
	normal: Normal,
	planeOrigin: Point,
	planeAxis: Axis
): (Point, number)
	local rpoint: Point = origin - planeOrigin
	local dot: number = -math.abs(normal:Dot(planeAxis))

	if dot == 0 then
		return origin, 0
	end

	local dist: number = -rpoint:Dot(planeAxis) / dot
	return origin + dist * normal, dist
end

--- Finds a normal that's not perpindicular to provided normal. I don't remember why I would ever need to do this, but I'm too afraid to remove it.
function Geometry.getNonPerpindicularNormal(normal: Normal): Normal
	local result = normal:Cross(Vector3.new(0, 1, 0))
	if math.abs(result:Dot(normal)) == 1 then
		result = normal:Cross(Vector3.new(1, 0, 0))
	end
	return result
end

--- When provided vertex A, vertex B, and line AC it solves for angle C
function Geometry.getSideLengthThroughLawOfSin(a: Radian, b: Radian, ac: Line): number
	return (ac[2] - ac[1]).Magnitude * math.sin(a) / math.sin(b)
end

--- Finds closest point on line a to the closest point on line b 
function Geometry.getClosestPointToLineOnLine(a: Line, b: Line): Point?
	local ori = a[1]
	local dir = a[2] - a[1]
	local norm = dir.Unit

	local oppOri = b[1]
	local oppDir = b[2] - b[1]
	local oppNorm = oppDir.Unit
	if oppNorm:Dot(norm) > 0 then
		oppOri = b[2]
		oppDir = b[1] - b[2]
		oppNorm = oppDir.Unit
	end

	local connectionLine = { ori, oppOri }
	local angle1 = Geometry.getAngleBetweenTwoLines(connectionLine, a)
	local angle2 = Geometry.getAngleBetweenTwoLines(connectionLine, b)
	local oppAngle = angle2
	local adjAngle = math.rad(180) - angle2 - angle1
	local sideLen = Geometry.getSideLengthThroughLawOfSin(oppAngle, adjAngle, connectionLine)
	return ori + norm * math.clamp(sideLen, 0, dir.Magnitude)
end

--- Gets the volume of a box with the provided dimensions.
function Geometry.getVolume(size: Vector3): number
	return size.X * size.Y * size.Z
end
--- Creates a list of triangles out of a sequential list of Vector2 or 3s, including support for a list of holes created with similar vertex sequences.
function Geometry.triangulate2D(vertices: PerimeterSequence<Vector2>, holes: {[number]: PerimeterSequence<Vector2>}?): {[number]: PerimeterSequence<Vector2>}
	local triangles: {[number]: PerimeterSequence<Vector2>} = {}
	holes = holes or {}
	assert(holes ~= nil)
	assert(vertices[1] ~= vertices[#vertices], "Perimeter has a duplicate index")
	for i, hole: PerimeterSequence<Vector2> in ipairs(holes) do
		assert(vertices[1] ~= vertices[#vertices], "Hole "..tostring(i).." has a duplicate ending index")
	end
	local earcutData: {	
		[number]: {
			[number]: {
				[number]: number
			}
		}
	} = {}

	local function insertPerimeterSequence(seq: PerimeterSequence<Vector2>): nil
		local vertData = {}
		for i, v2: Vector2 in ipairs(seq) do
			local vertTabl = {
				[1] = v2.X,
				[2] = v2.Y,
			}
			vertData[i] = vertTabl
		end
		table.insert(earcutData, vertData)
		return nil
	end
	insertPerimeterSequence(vertices)
	for i, holeSequence: PerimeterSequence<Vector2> in ipairs(holes) do
		insertPerimeterSequence(holeSequence)
	end

	local earcutVertices: {[number]: number} = {}
	local holeIndeces: {[number]: number} = {}
	local earcutMax: {[number]: number} = {}
	local earcutMin: {[number]: number} = {}
	local holeIndex = 1
	local dim = 2

	for i = 1, #earcutData do --shape
		for j = 1, #earcutData[i] do --vertex
			for d = 1, dim do
				earcutMax[d] = math.max(earcutMax[d] or -math.huge, earcutData[i][j][d])
				earcutMin[d] = math.min(earcutMin[d] or math.huge, earcutData[i][j][d])
				table.insert(earcutVertices, earcutData[i][j][d])
			end
		end
		if i > 1 then
			holeIndex = holeIndex + #earcutData[i - 1]
			table.insert(holeIndeces, holeIndex)
		end
	end


	local rawTriangles: {[number]: number} = Earcut(earcutData, holeIndeces, 2)
	for i = 1, #rawTriangles, 3 do
		local aRaw, bRaw, cRaw = rawTriangles[i], rawTriangles[i+1], rawTriangles[i+2]
		assert(aRaw ~= nil and bRaw ~= nil and cRaw ~= nil)

		local aIndex = (aRaw * 2) + 1
		local bIndex = (bRaw * 2) + 1
		local cIndex = (cRaw * 2) + 1

		local triangle: PerimeterSequence<Vector2> = {
			Vector2.new(earcutVertices[aIndex], earcutVertices[aIndex + 1]),
			Vector2.new(earcutVertices[bIndex], earcutVertices[bIndex + 1]),
			Vector2.new(earcutVertices[cIndex], earcutVertices[cIndex + 1]),
		}
		table.insert(triangles, triangle)	
	end
	
	return triangles
end

--- Flattens a list of Vector3s into Vector2s using the zAxis
function Geometry.flattenPerimeterSequence(sequence: PerimeterSequence<Vector3>, origin: CFrame): (PerimeterSequence<Vector2>, {[Vector2]: Vector3})
	local base:  CFrame = origin:Inverse() 

	local finalVertices: {[number]: Vector2} = {}
	local reference: {[Vector2]: Vector3} = {}
	for i, vec: Vector3 in ipairs(sequence) do
		local offset: CFrame = base*CFrame.new(vec)
		finalVertices[i] = Vector2.new(offset.X, offset.Y)
		reference[finalVertices[i]] = vec
	end
	return finalVertices, reference
end

--- Triangulates a list of 3d sequential points similar to triangulate2D.
function Geometry.triangulate3D<V>(origin: CFrame, perimeter: PerimeterSequence<Vector3>, holes: {[number]: PerimeterSequence<Vector3>}?): {[number]: PerimeterSequence<Vector3>}
	local holeV2Sequences = {}
	local reference = {}
	for i, holeSeq in ipairs(holes or {}) do
		local holeReference
		holeV2Sequences[i], holeReference = Geometry.flattenPerimeterSequence(holeSeq, origin)
		for i, vec: Vector2 in ipairs(holeV2Sequences[i]) do
			reference[vec] = holeReference[vec]
		end
	end
	local perimeterV2, perimeterReference = Geometry.flattenPerimeterSequence(perimeter, origin)
	for i, vec: Vector2 in ipairs(perimeterV2) do
		reference[vec] = perimeterReference[vec]
	end

	local triangles2D = Geometry.triangulate2D(perimeterV2, holeV2Sequences)
	local triangles3D: {[number]: PerimeterSequence<Vector3>} = {}
	for i, triangle2D: {[number]: Vector2} in ipairs(triangles2D) do
		local triangle3D: {[number]: Vector3} = {}
		for d, vertex2D: Vector2 in ipairs(triangle2D) do
			triangle3D[d] = reference[vertex2D]
		end
		triangles3D[i] = triangle3D
	end
	return triangles3D
end



return Geometry
