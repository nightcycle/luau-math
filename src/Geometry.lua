


--!strict
function deduplicateList(list: {[number]: any}): {[number]: any}
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

local Geometry = {}

function Geometry.getLineLength(line: Line): number
	return (line[1] - line[2]).Magnitude
end

function Geometry.getLineLengths(lines: {[any]: Line}): {[any]: number}
	local lineLengths = {}
	for k, line in pairs(lines) do
		lineLengths[k] = Geometry.getLineLength(line)
	end
	return lineLengths
end

function Geometry.getLineCenter(line: Line): Point
	return line[1]:Lerp(line[2], 0.5)
end

function Geometry.getLineCenters(lines: {[any]: Line}): {[any]: Point}
	local lineCenters = {} :: {[any]: Point}
	for k, line in pairs(lines) do
		lineCenters[k] = Geometry.getLineCenter(line)
	end
	return lineCenters
end

function Geometry.getLineAxis(line: Line): Axis
	return (line[1] - line[2]).Unit
end

function Geometry.getLineAxes(lines: {[string]: Line}): {[string]: Axis}
	local lineAxes = {}
	for k, line in pairs(lines) do
		lineAxes[k] = Geometry.getLineAxis(line)
	end
	return lineAxes
end

function Geometry.getIfVerticesConnected(a: Vertex, b: Vertex, lines : {[any]:Line}): boolean
	for k, line in pairs(lines) do
		if (line[1] == a and line[2] == b) or (line[1] == b and line[2] == a) then
			return true
		end
	end
	return false
end

function Geometry.getConnectedVertices(vertex: Vertex, lines: {[any]:Line}): {[number]: Vertex}
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

function Geometry.getAllVerticesFromLines(lines: {[string]: Line}): {[number]: Vertex}
	local vertices = {}
	for k, line in pairs(lines) do
		table.insert(vertices, line[1])
		table.insert(vertices, line[2])
	end
	return deduplicateList(vertices)
end

function Geometry.getAllVertexConnectionsFromLines(lines: {[string]: Line}): {[Vertex]: {[number]: Vertex}}
	local connectedVertexRegistry: {[Vertex]: {[Vertex]: boolean}} = {}
	for k, line in pairs(lines) do
		connectedVertexRegistry[line[1]] = connectedVertexRegistry[line[1]] or {}
		connectedVertexRegistry[line[1]][line[2]] = true
		connectedVertexRegistry[line[2]] = connectedVertexRegistry[line[2]] or {}
		connectedVertexRegistry[line[2]][line[1]] = true
	end
	local connectedVertices = {}
	for v: Vertex, registry: {[Vertex]: boolean} in pairs(connectedVertexRegistry) do
		local list = {}
		for connection: Vertex, _ in pairs(registry) do
			table.insert(list, connection)
		end
		connectedVertices[v] = list
	end
	return connectedVertices
end

function Geometry.getSharedVertex(line1: Line, line2: Line): Vertex | nil
	local result: Vector3 | nil
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

function Geometry.getIfRightAngle(vertex: Vertex, line1: Line, line2: Line): boolean
	local connectedVertices = Geometry.getConnectedVertices(vertex, {line1, line2})
	local norm1: Normal = (vertex - connectedVertices[1]).Unit
	local norm2: Normal = (vertex - connectedVertices[2]).Unit
	local dot = norm1:Dot(norm2)
	return math.round(dot * 100)/100 == 0
end

function Geometry.getIfRightAngleFromVertices(sharedVertex: Vertex, vertices: {[number]: Vector3}): boolean
	local line1: Line = {sharedVertex, vertices[1]}
	local line2: Line = {sharedVertex, vertices[2]}
	return Geometry.getIfRightAngle(sharedVertex, line1, line2)
end

function Geometry.getRightAngleVertices(lines: {[string]: Line}): {[number]: Vertex}
	local connectedVertices = Geometry.getAllVertexConnectionsFromLines(lines)
	local rightAngles = {}
	for v, connections in pairs(connectedVertices) do
		if Geometry.getIfRightAngleFromVertices(v, {connections[1], connections[2]}) then
			table.insert(rightAngles, v)
		end
	end
	return rightAngles
end

function Geometry.getIntersectionBetweenTwoLines(line1: Line, line2: Line): Point | nil
	local start1: Vertex = line1[1]
	local start2: Vertex = line2[1]
	
	local finish1: Vertex = line1[2]
	local finish2: Vertex = line2[2]

	local step = 0.01

	local direction1: Normal = (finish1 - start1).Unit
	local direction2: Normal = (finish2 - start2).Unit

	local step1: Vector3 = start1 + direction1 * step
	local step2: Vector3 = start2 + direction2 * step

	local startSeparation: number = (start1-start2).Magnitude
	local stepSeparation: number = (step1-step2).Magnitude
	local separationSlope : number = ((stepSeparation - startSeparation)/(step1-start1)).Magnitude

	local result: Point | nil
	if separationSlope < 0 then --getting closer
		 local distance: number = -startSeparation/separationSlope
		 result = start1 + direction1 * distance
	elseif separationSlope > 0 then --getting farther
		result = start1
	end
	return result
end

function Geometry.getVertexOppositePointsFromLines(lines: {[any]: Line}): {[Vertex]: Point}
	local corners: {[number]: Vertex} = Geometry.getRightAngleVertices(lines)
	local vertices: {[number]: Vertex} = Geometry.getAllVerticesFromLines(lines)
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


function Geometry.getDiagonalLinesFromEdges(lines: {[any]: Line}): {[number]: Line}
	local opposites: {[Vertex]: Point} = Geometry.getVertexOppositePointsFromLines(lines)

	local diagonalRegistry: {[Vertex]: Line} = {}
	for a, b in pairs(opposites) do
		if not diagonalRegistry[a] and not diagonalRegistry[b] then
			diagonalRegistry[a] = {a,b} :: Line
		end
	end

	local diagonals: {[number]: Line} = {}
	for _, line in pairs(diagonalRegistry) do
		table.insert(diagonals, line)
	end

	return diagonals
end

function Geometry.getTrianglePerimeter(a: Vertex, b: Vertex, c: Vertex): number
	local ab: number = (a-b).Magnitude
	local bc: number = (b-c).Magnitude
	local ca: number = (c-a).Magnitude
	return ab + bc + ca
end

function Geometry.getTriangleArea(a: Vertex, b: Vertex, c: Vertex): number --heron's formula
	local perimeter: number = Geometry.getTrianglePerimeter(a,b,c)
	local semiPerimeterLength: number = perimeter/2

	local aLength: number = (a-b).Magnitude
	local bLength: number = (b-c).Magnitude
	local cLength: number = (c-a).Magnitude

	local deltaA: number = (semiPerimeterLength-aLength)
	local deltaB: number = (semiPerimeterLength-bLength)
	local deltaC: number = (semiPerimeterLength-cLength)

	return math.sqrt(semiPerimeterLength*deltaA*deltaB*deltaC)
end

function Geometry.getIfPointIsInTriangle(point: Point, a: Vertex, b: Vertex, c: Vertex): boolean
	local abc = Geometry.getTriangleArea(a, b, c)
	local pbc = Geometry.getTriangleArea(point, b, c)
	local abp = Geometry.getTriangleArea(a, b, point)
	return abc == pbc + abc + abp
end

function Geometry.getAngleThroughLawOfCos(lineA: Line, lineB: Line, lineC: Line): Radian
	local a = Geometry.getLineLength(lineA)
	local b = Geometry.getLineLength(lineB)
	local c = Geometry.getLineLength(lineC)
	if math.round(1000*(a+b)) == math.round(1000*c) then return 0 end
	-- print("A", a, "B", b, "C", c)
	local numerator = (a^2) + (b^2) - (c^2)
	local denominator = (2*a*b)
	local frac = numerator/denominator
	local angle = math.acos(frac)

	return angle
end

function Geometry.getAngleBetweenTwoLines(line1: Line, line2: Line): Radian
	local corner = Geometry.getSharedVertex(line1, line2)
	local line3 = {
		if line1[1] == corner then line1[2] else line1[1],
		if line2[1] == corner then line2[2] else line2[1],
	}
	return Geometry.getAngleThroughLawOfCos(line1, line2, line3)
end

function Geometry.getSideLengthThroughLawOfCos(angle: number, lineA: Line, lineB: Line): number
	local a: number = Geometry.getLineLength(lineA)
	local b: number = Geometry.getLineLength(lineB)
	return math.sqrt((a^2) + (b^2) - (2*a*b*math.cos(angle)))
end

function Geometry.getLineInwardNormal(line: Line, centerPoint: Vector3): Normal --does not just aim towards center point, only works on concave shapes
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

function Geometry.getClosestPointInList(point: Point, list: {[number]: Point}): Point
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

function Geometry.getFarthestPointInList(point: Point, list: {[number]: Point}): Point
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

function Geometry.getClosestPointOnLine(point: Point, line: Line)
	local start: Vertex = line[1]
	local fin: Vertex = line[2]

	local angleS: Radian = Geometry.getAngleThroughLawOfCos({point, start}, line, {point, fin})

	local adjDist: number =  math.min(math.cos(angleS)*(point-start).Magnitude, (start-fin).Magnitude)

	return start + (fin - start).Unit * adjDist
end

function Geometry.getLineClosestToPoint(point: Point, lines: {[any]: Line}): Line
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

function Geometry.getCenterFromLines(lines: {[any]: Line}): Point | nil
	local diagonals: {[number]: Line} = Geometry.getDiagonalLinesFromEdges(lines)
	local result: Point | nil
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

function Geometry.getSurfaceCFrameFromLines(lines: {[any]: Line}, normal: Normal): CFrame
	local longestLine: Line = nil
	local longestLength: number = 0
	for i, line in pairs(lines) do
		local length = Geometry.getLineLength(line)
		if longestLength < length then
			longestLength = length
			longestLine = line
		end
	end

	local centerPoint: Point | nil = Geometry.getCenterFromLines(lines)
	assert(centerPoint ~= nil, "Bad center point")
	local lineInwardNormal: Normal = Geometry.getLineInwardNormal(longestLine, centerPoint)

	local zVec: Normal = -lineInwardNormal
	local yVec: Normal = normal
	local xVec: Normal = zVec:Cross(yVec)

	return CFrame.fromMatrix(centerPoint, xVec, yVec, zVec)
end

function Geometry.getBoxBoundaries(cf: CFrame, size: Vector3): (Point, Point) 
	local half = size*0.5
	local min: Point = (cf * CFrame.new(-half.X, -half.Y, -half.Z)).Position
	local max: Point = (cf * CFrame.new(half.X, half.Y, half.Z)).Position
	return min, max
end

function Geometry.getPlaneIntersection(point: Point, normal: Normal, planeOrigin: Point, planeAxis: Axis): (Point, number)
	local rpoint: Point = point - planeOrigin
	local dot: number = -math.abs(normal:Dot(planeAxis))

	if dot == 0 then
		return point, 0
	end

	local dist: number = -rpoint:Dot(planeAxis) / dot
	return point + dist * normal, dist
end

function Geometry.getVolume(size: Vector3): number
	return size.X * size.Y * size.Z
end

return Geometry