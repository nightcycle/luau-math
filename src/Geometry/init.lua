--[=[
	A utility useful for working with BasePart related geometry. Vertices are Vector3s, Lines are simply lists with 2 vertices in them. Surfaces are a combination of a direction and a list of lines.
	@class Geometry
]=]

local Geometry = {}

--[=[
	@method getLineLength
	Gets the length of a line
	@within Geometry
	@param line [Vector3] -- a list of the 2 vertices that compose the straight line
	@return number
]=]
function Geometry.getLineLength(line: {[number]: Vector3})
	return (line[1] - line[2]).Magnitude
end

--[=[
	@method getLineLengths
	Gets the length of multiple lines
	@within Geometry
	@param lines [[Vector3]] -- a list of line vertex lists
	@return [number] --list of lengths
]=]
function Geometry.getLineLengths(lines: {[string]: {[number]: Vector3}})
	local lineLengths = {}
	for k, line in pairs(lines) do
		lineLengths[k] = Geometry.getLineLength(line)
	end
	return lineLengths
end

--[=[
	@method getLineCenter
	Gets the point on a line equidistant from the two vertices
	@within Geometry
	@param line [Vector3] -- a list of the 2 vertices that compose the straight line
	@return Vector3
]=]
function Geometry.getLineCenter(line: {[number]: Vector3})
	-- print(line)
	return line[1]:Lerp(line[2], 0.5)
end

--[=[
	@method getLineCenter
	Performs getLineCenter on a list of lines.
	@within Geometry
	@param lines [[Vector3]] -- a list of line vertex lists
	@return [Vector3] --a list of centers
]=]
function Geometry.getLineCenters(lines: {[string]: {[number]: Vector3}})
	local lineCenters = {}
	for k, line in pairs(lines) do
		lineCenters[k] = Geometry.getLineCenter(line)
	end
	return lineCenters
end

--[=[
	@method getLineAxis
	Gets the direction of the line
	@within Geometry
	@param line [Vector3] -- a list of vertices composing the line
	@return Vector3 --the normalized unit direction of the line that can be used as an axis
]=]
function Geometry.getLineAxis(line: {[number]: Vector3})
	return (line[1] - line[2]).Unit
end

--[=[
	@method getLineAxes
	Performs getLineAxis on a list of lines.
	@within Geometry
	@param lines [[Vector3]] -- a list of line vertex lists
	@return [Vector3] --a list of axes
]=]
function Geometry.getLineAxes(lines: {[string]: {[number]: Vector3}})
	local lineAxes = {}
	for k, line in pairs(lines) do
		lineAxes[k] = Geometry.getLineAxis(line)
	end
	return lineAxes
end

--[=[
	@method getDeduplicatedList
	Quickly goes through and removes duplicates from a list, something useful when seeing if two lines share a vertex. Order of items in list is not maintained.
	@within Geometry
	@param list [any] -- a list
	@return [any] -- a deduplicated list
]=]
function Geometry.getDeduplicatedList(list: table)
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

--[=[
	@method getIfVerticesConnected
	Checks to see if two vertices share a line
	@within Geometry
	@param vertexA Vector3 -- the first vertex used in comparison
	@param vertexB Vector3 -- the second vertex used in comparison
	@param lines [[Vector3]] -- a list of line vertex lists that contain either of the vertices
	@return boolean
]=]
function Geometry.getIfVerticesConnected(v1: Vector3, v2: Vector3, lines: {[string]: {[number]: Vector3}})
	for i, line in ipairs(lines) do
		if (line[1] == v1 and line[2] == v2) or (line[1] == v2 and line[2] == v1) then
			return true
		end
	end
	return false
end

--[=[
	@method getConnectedVertices
	Gets all vertices connected by a line to a single vertex
	@within Geometry
	@param vertex Vector3 -- the vertex to use to find other vertices
	@param lines [[Vector3]] -- a list of line vertex lists that contain the vertex
	@return [Vector3] -- a list of relevant vertices not including the initial vertex
]=]
function Geometry.getConnectedVertices(vertex: Vector3, lines: {[string]: {[number]: Vector3}})
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

--[=[
	@method getAllVerticesFromLines
	Compiles a deduplicated list of all vertices used within a list of lines
	@within Geometry
	@param lines [[Vector3]] -- a list of line vertex lists
	@return [Vector3] -- a list of vertices
]=]
function Geometry.getAllVerticesFromLines(lines: {[string]: {[number]: Vector3}})
	local vertices = {}
	for i, line in ipairs(lines) do
		table.insert(vertices, line[1])
		table.insert(vertices, line[2])
	end
	return Geometry.getDeduplicatedList(vertices)
end

--[=[
	@method getAllVertexConnectionsFromLines
	Goes through a dictionary with the key of each vertex, and the value being a list of all vertices within the lines that they connect to.
	@within Geometry
	@param lines [[Vector3]] -- a list of line vertex lists
	@return {Vector3: [Vector3]}
]=]
function Geometry.getAllVertexConnectionsFromLines(lines: {[string]: {[number]: Vector3}})
	local connectedVertexRegistry = {}
	for k, line in pairs(lines) do
		connectedVertexRegistry[line[1]] = connectedVertexRegistry[line[1]] or {}
		connectedVertexRegistry[line[1]][line[2]] = true
		connectedVertexRegistry[line[2]] = connectedVertexRegistry[line[2]] or {}
		connectedVertexRegistry[line[2]][line[1]] = true
	end
	local connectedVertices = {}
	for v3, registry in pairs(connectedVertexRegistry) do
		local list = {}
		for connection, _ in pairs(registry) do
			table.insert(list, connection)
		end
		connectedVertices[v3] = list
	end
	return connectedVertices
end
--[=[
	@method getSharedVertex
	Takes to lines and returns the shared vertex between them if there is one.
	@within Geometry
	@param lineA [Vector3] -- a line vertex list to compare to lineB
	@param lineB [Vector3] -- a line vertex list to compare to lineA
	@return Vector3 | nil
]=]
function Geometry.getSharedVertex(line1: {[number]: Vector3}, line2: {[number]: Vector3})
	for i, a in ipairs(line1) do
		for j, b in ipairs(line2) do
			if a == b then return a end
		end
	end
end

--[=[
	@method getIfRightAngle
	Checks to see if two lines form a right angle in 3D space.
	@within Geometry
	@param vertex: Vector3 -- the corner vertex
	@param lineA [Vector3] -- a line vertex list making up one half of the angle
	@param lineB [Vector3] -- a line vertex list making up the other half of the angle
	@return boolean
]=]
function Geometry.getIfRightAngle(vertex: Vector3, line1: {[number]: Vector3}, line2: {[number]: Vector3})
	local connectedVertices = Geometry.getConnectedVertices(vertex, {line1, line2})
	local direction1 = (vertex - connectedVertices[1]).Unit
	local direction2 = (vertex - connectedVertices[2]).Unit
	local dot = direction1:Dot(direction2)
	return math.round(dot * 100)/100 == 0
end

--[=[
	@method getIfRightAngleFromVertices
	A wrapper for getIfRightAngle that uses vertices.
	@within Geometry
	@param sharedVertex: Vector3 -- the corner vertex
	@param vertices: [Vector3] --a list of two vertices used to create the angle lines
	@return boolean
]=]
function Geometry.getIfRightAngleFromVertices(sharedVertex: Vector3, vertices: {[number]: Vector3})
	local line1 = {sharedVertex, vertices[1]}
	local line2 = {sharedVertex, vertices[2]}
	return Geometry.getIfRightAngle(sharedVertex, line1, line2)
end

--[=[
	@method checkIfInList
	A wrapper for getIfRightAngle that uses vertices.
	@within Geometry
	@param value: any -- the value being searched for
	@param list: [any] --a list to search through
	@return boolean
]=]
function Geometry.checkIfInList(value, list)
	for i, v in ipairs(list) do
		if v == value then return true end
	end
	return false
end


function round(number, precision)
	if precision then
		return math.floor((number/precision) + 0.5) * precision
	else
		return math.floor(number + 0.5)
	end
end

--[=[
	@method roundVector3
	Because Roblox stores Vector3s in pretty high precision, you can sometime see drift between seemingly identical vectors. By rounding them to a less precise increment you increase the chance of not getting a false negative when checking if two are equal.
	@within Geometry
	@param vector: Vector3 -- the vector to be rounded
	@param roundingIncrement: number -- the nearest increment to be rounded to (ex: 0.86346 with an increment of 0.05 would equal 0.85)
	@return Vector3
]=]
function Geometry.roundVector3(vector3, roundingIncrement)
	local x = round(vector3.X, roundingIncrement)
	local y = round(vector3.Y, roundingIncrement)
	local z = round(vector3.Z, roundingIncrement)
	return Vector3.new(x,y,z)
end

--[=[
	@method getRightAngleVertices
	Assembles a list of all vertices which serve as the corners of right angles.
	@within Geometry
	@param lines [[Vector3]] -- a list of line vertex lists
	@return boolean
]=]
function Geometry.getRightAngleVertices(lines: {[string]: {[number]: Vector3}})
	local connectedVertices = Geometry.getAllVertexConnectionsFromLines(lines)
	local rightAngles = {}
	for v, connections in pairs(connectedVertices) do
		if Geometry.getIfRightAngleFromVertices(v, {connections[1], connections[2]}) then
			table.insert(rightAngles, v)
		end
	end
	return rightAngles
end

--[=[
	@method getIntersectionBetweenTwoLines
	Assembles a list of all vertices which serve as the corners of right angles. If no intersection within line bounds it splits the difference between closest points. Returns nil if parallel.
	@within Geometry
	@param lineA [Vector3] -- the first line vertex list used
	@param lineB [Vector3] -- the second line vertex list used
	@return Vector3 | nil
]=]
function Geometry.getIntersectionBetweenTwoLines(line1, line2)
	local start1 = line1[1]
	local start2 = line2[1]
	
	local finish1 = line1[2]
	local finish2 = line2[2]

	local step = 0.01

	local direction1 = (finish1 - start1).Unit
	local direction2 = (finish2 - start2).Unit

	local step1 = start1 + direction1 * step :: number
	local step2 = start2 + direction2 * step :: number

	local length1 = (finish1 - start1).Magnitude :: number
	local length2 = (finish2 - start2).Magnitude :: number

	local startSeparation = (start1-start2).Magnitude :: number
	local stepSeparation = (step1-step2).Magnitude :: number
	local separationSlope = (stepSeparation - startSeparation)/(step1-start1).Magnitude :: number

	if separationSlope < 0 then --getting closer
		 local distance = -startSeparation/separationSlope
		 return start1 + direction1 * distance
	elseif separationSlope > 0 then --getting farther
		return start1
	elseif separationSlope == 0 then --parallel
		return nil
	end
end

--[=[
	@method getVertexOppositePointFromLines
	Attempts to find the opposite point for a set of lines within a surface, returning a dictionary of the associated opposite position for each vertex. Corners go for diagonal corners, splitting the opposite line if there is none.
	@within Geometry
	@param lines [[Vector3]] -- a list of line vertex lists
	@return {Vector3 : Vector3}
]=]
function Geometry.getVertexOppositePointFromLines(lines: {[string]: {[number]: Vector3}})
	local corners = Geometry.getRightAngleVertices(lines)
	local vertices = Geometry.getAllVerticesFromLines(lines)
	-- print(vertices, lines)
	local oppositeRegistry = {}
	local opposites = {}
	-- print("Corner count", #corners, corners)
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
--[=[
	@method mergeLists
	Combines a series of passed lists into a single list.
	@within Geometry
	@param ... [any] -- each parameter is added to a composite list, but not deduplicated. Lists are added in order of passing.
	@return [any]
]=]
function Geometry.mergeLists(...)
	local finalList = {}
	for i, list in ipairs({...}) do
		for j, v in ipairs(list) do
			table.insert(finalList, v)
		end
	end
	return finalList
end

--[=[
	@method getDiagonalLinesFromEdges
	Takes the opposite points generated by getVertexOppositePointFromLines and uses it to construct diagonal lines between opposite points.
	@within Geometry
	@param lines [[Vector3]] -- a list of line vertex lists
	@return [[Vector3]] -- a list of diagonal lines
]=]
function Geometry.getDiagonalLinesFromEdges(lines: {[string]: {[number]: Vector3}})
	local opposites = Geometry.getVertexOppositePointFromLines(lines)
	local diagonalRegistry = {}
	for a, b in pairs(opposites) do
		if not diagonalRegistry[a] and not diagonalRegistry[b] then
			diagonalRegistry[a] = {a,b}
		end
	end
	local diagonals = {}
	for _, line in pairs(diagonalRegistry) do
		table.insert(diagonals, line)
	end
	-- print(diagonals, diagonalRegistry, lines)
	return diagonals
end

--[=[
	@method getTrianglePerimeter
	Makes a triangle out of three points and calculates its perimeter
	@within Geometry
	@param a Vector3 -- vertex A on triangle
	@param b Vector3 -- vertex B on triangle
	@param c Vector3 -- vertex C on triangle
	@return number -- length of perimeter
]=]
function Geometry.getTrianglePerimeter(a: Vector3, b:Vector3, c:Vector3)
	local ab = (a-b).Magnitude
	local bc = (b-c).Magnitude
	local ca = (c-a).Magnitude
	return ab + bc + ca
end

--[=[
	@method getTriangleArea
	Makes a triangle out of three points and calculates its area using heron's formula
	@within Geometry
	@param a Vector3 -- vertex A on triangle
	@param b Vector3 -- vertex B on triangle
	@param c Vector3 -- vertex C on triangle
	@return number -- area of triangle
]=]
function Geometry.getTriangleArea(a: Vector3, b: Vector3, c:Vector3) --heron's formula
	local perimeter = Geometry.getTrianglePerimeter(a,b,c)
	local s = perimeter/2
	return math.sqrt(s*(s-a)*(s-b)*(s-c))
end

--[=[
	@method getIfPointIsInTriangle
	Checks if a point is on the surface of a triangle - it's recommended you round the points as this method is very exact.
	@within Geometry
	@param point Vector3 -- the point being looked for in triangle
	@param a Vector3 -- vertex A on triangle
	@param b Vector3 -- vertex B on triangle
	@param c Vector3 -- vertex C on triangle
	@return boolean
]=]
function Geometry.getIfPointIsInTriangle(p: Vector3, a: Vector3, b: Vector3, c: Vector3)
	local abc = Geometry.getTriangleArea(a, b, c)
	local pbc = Geometry.getTriangleArea(p, b, c)
	local apc = Geometry.getTriangleArea(a, p, c)
	local abp = Geometry.getTriangleArea(a, b, p)
	return abc == pbc + abc + abp
end

--[=[
	@method getAngleThroughLawOfCos
	Gets the angle of a corner of a triangle using just its side lengths
	@within Geometry
	@param lineA [Vector3] -- the first line vertex list used
	@param lineB [Vector3] -- the second line vertex list used
	@param lineC [Vector3] -- the third line vertex list used
	@return number -- radians
]=]
function Geometry.getAngleThroughLawOfCos(lineA: {[number]: Vector3}, lineB: {[number]: Vector3}, lineC: {[number]: Vector3})
	local a = Geometry.getLineLength(lineA)
	local b = Geometry.getLineLength(lineB)
	local c = Geometry.getLineLength(lineC)
	if math.round(1000*(a+b)) == math.round(1000*c) then return 0 end
	-- print("A", a, "B", b, "C", c)
	local numerator = (a^2) + (b^2) - (c^2)
	local denominator = (2*a*b)
	local frac = numerator/denominator
	local angle = math.acos(frac)

	-- print("N", numerator, "D", denominator, "F", frac, "A", angle)
	return angle
end


function Geometry.getAngleBetweenTwoLines(line1, line2)
	local corner = Geometry.getSharedVertex(line1, line2)
	local line3 = {
		if line1[1] == corner then line1[2] else line1[1],
		if line2[1] == corner then line2[2] else line2[1],
	}
	return Geometry.getAngleThroughLawOfCos(line1, line2, line3)
end

--[=[
	@method getSideLengthThroughLawOfCos
	Gets the length of line opposite to angle using angle and the two connected lines
	@within Geometry
	@param angle number -- the angle in radians used to solve for opposite side length
	@param lineA [Vector3] -- the first line vertex list used
	@param lineB [Vector3] -- the second line vertex list used
	@return number
]=]
function Geometry.getSideLengthThroughLawOfCos(angle: number, lineA: {[number]: Vector3}, lineB: {[number]: Vector3})
	local a = Geometry.getLineLength(lineA)
	local b = Geometry.getLineLength(lineB)
	return math.sqrt((a^2) + (b^2) - (2*a*b*math.cos(angle)))
end

--[=[
	@method getLineInwardVector
	Creates a vector parallel to surface, but perpindicular to line axis, facing inwards. Works with any concave shape
	@within Geometry
	@param line [Vector3] -- the line used in surface
	@param centerPoint Vector3 -- the point at center of surface
	@return Vector3
]=]
function Geometry.getLineInwardVector(line: {[number]: Vector3}, centerPoint: Vector3) --does not just aim towards center point, only works on concave shapes
	local lineCenter = Geometry.getLineCenter(line)
	local lV = (line[2] - line[1]).Unit
	local directionToCenter = (lineCenter - centerPoint).Unit
	local uV = lV:Cross(directionToCenter)
	local rV = uV:Cross(lV)
	local dot = rV:Dot(directionToCenter)
	if dot > 0 then
		return rV
	else
		return -rV
	end
end

--[=[
	@method getClosestPointInList
	Finds the point in a list closest to another specified point
	@within Geometry
	@param focus Vector3 -- the point every other point is measuring distance with
	@param points [Vector3] -- a list of points to compare
	@return Vector3 | nil -- will return nil if list is empty
]=]
function Geometry.getClosestPointInList(point, list: {[number]: Vector3})
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

--[=[
	@method getFarthestPointInList
	Finds the point in a list farthest from another specified point
	@within Geometry
	@param point Vector3 -- the point every other point is measuring distance with
	@param points [Vector3] -- a list of points to compare
	@return Vector3 | nil -- will return nil if list is empty
]=]
function Geometry.getFarthestPointInList(point, list: {[number]: Vector3})
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


--[=[
	@method getClosestPointOnLine
	Finds the point anywhere along line that's closest to specified point.
	@within Geometry
	@param point Vector3 -- the point used to find closest point on line
	@param line [Vector3] -- a line vertex list
	@return Vector3
]=]
function Geometry.getClosestPointOnLine(vertex: Vector3, line: {[number]: Vector3})
	local start = line[1]
	local fin = line[2]

	local angleS = Geometry.getAngleThroughLawOfCos({vertex, start}, line, {vertex, fin})

	local adjDist =  math.min(math.cos(angleS)*(vertex-start).Magnitude, (start-fin).Magnitude)

	return start + (fin - start).Unit * adjDist
end

--[=[
	@method getLineClosestToPoint
	Gets the closest point for each line from provided point, then returns the line with the closest closest point.
	@within Geometry
	@param point Vector3 -- the point used to find closest point on line
	@param lines [[Vector3]] -- a list of line vertex lists
	@return [Vector3]
]=]
function Geometry.getLineClosestToPoint(point: Vector3, lines: {[string]: {[number]: Vector3}})
	local closestLine
	local closestDist = math.huge
	for i, line in ipairs(lines) do
		local closestPoint = Geometry.getClosestPointOnLine(point, line)
		local dist = (closestPoint - point).Magnitude
		if closestDist > dist then
			closestDist = dist
			closestLine = line
		end
	end
	return closestLine
end

--[=[
	@method getCenterFromLines
	finds the center/centroid of any convex 3-4 sided shape from its lines
	@within Geometry
	@param lines [[Vector3]] -- a list of line vertex lists
	@return Vector3
]=]
function Geometry.getCenterFromLines(lines: {[string]: {[number]: Vector3}})
	local diagonals = Geometry.getDiagonalLinesFromEdges(lines)
	if #lines == 4 then
		return Geometry.getLineCenter(diagonals[1])
	elseif #lines == 3 then
		local vertices = Geometry.getAllVerticesFromLines(lines)
		local corners = Geometry.getRightAngleVertices(lines)
		if #corners == 1 then
			-- print("Square triangle")
			local corner = corners[1]
			local a,b
			if vertices[1] == corner then 
				a = vertices[1]
				b = vertices[2]
			elseif vertices[2] == corner then
				a = vertices[1]
				b = vertices[3]
			else
				a = vertices[1]
				b = vertices[2]
			end
			return Geometry.getIntersectionBetweenTwoLines(diagonals[1], diagonals[2])
		else
			local a = vertices[1]
			local b = vertices[3]
			local c = vertices[2]
			local ab = a:Lerp(b, 0.5)
			return ab:Lerp(c, 0.66)
		end
	end
end

--[=[
	@method getSurfaceCFrameFromLines
	returns a cframe at the surface's center, oriented with the normal as the YVector and the longest line direction as the ZVector
	@within Geometry
	@param lines [[Vector3]] -- lines that compose the surface
	@param normal Vector3 -- the surface normal to match up
	@return CFrame
]=]
function Geometry.getSurfaceCFrameFromLines(lines: {[string]: {[number]: Vector3}}, normal)
	local longestLine = nil
	local longestLength = 0
	for i, line in ipairs(lines) do
		local length = Geometry.getLineLength(line)
		if longestLength < length then
			longestLength = length
			longestLine = line
		end
	end
	local centerPoint = Geometry.getCenterFromLines(lines)
	local lineInwardDirection = Geometry.getLineInwardVector(longestLine, centerPoint)
	local lV = -lineInwardDirection
	local uV = normal
	local rV = lV:Cross(uV)
	return CFrame.fromMatrix(centerPoint, rV, uV)
end

--[=[
	@method getSurfaceLinesFromNormal
	returns all the lines of the first surface with a normal that has a dot product > 0.9
	@within Geometry
	@param basePart BasePart -- the basePart to get surfaces from
	@param normal Vector3 -- the surface normal to match up
	@return [[Vector3]]
]=]
function Geometry.getSurfaceLinesFromNormal(basePart: BasePart, norm: Vector3)
	local surfaceDirections, surfaceLines = Geometry.getSurfaces(basePart)
	local selectedLines = nil
	for k, v3 in pairs(surfaceDirections) do
		local dot = v3:Dot(norm)
		if dot > 0.9 then
			selectedLines = surfaceLines[k]
		end
	end
	return selectedLines
end

--[=[
	@method export
	exports a table of properties needed to rebuild part on server side
	@within Geometry
	@param basePart BasePart -- the basePart to get surfaces from
	@return table
]=]
function Geometry.export(basePart: BasePart)
	return {
		ClassName = basePart.ClassName,
		CFrame = basePart.CFrame,
		Size = basePart.Size,
		Color = basePart.Color,
		Material = basePart.Material,
		Transparency = basePart.Transparency,
		Reflectance = basePart.Reflectance,
		Attributes = basePart:GetAttributes(),
	}
end

--[=[
	@method import
	imports a table of properties and rebuilds part on server side
	@within Geometry
	@param data table -- the basePart to get surfaces from
	@return BasePart
]=]
function Geometry.import(data)
	local basePart = Instance.new(data.ClassName)
	basePart.CFrame = data.CFrame
	basePart.Size = data.Size
	basePart.Color = basePart.Color
	basePart.Material = basePart.Material
	basePart.Transparency = basePart.Transparency
	basePart.Reflectance = basePart.Reflectance

	for k, v in pairs(data.Attributes) do
		basePart:SetAttribute(k, v)
	end
	return basePart
end

function Geometry.getBoxBoundaries(cf: CFrame, size: Vector3)
	local half = size*0.5
	local min = cf * CFrame.new(-half.X, -half.Y, -half.Z)
	local max = cf * CFrame.new(half.X, half.Y, half.Z)
	return min, max
end

function Geometry.getPlaneIntersection(point: Vector3, normal: Vector3, planeOrigin: Vector3, planeAxis: Vector3)
	local rpoint = point - planeOrigin
	local dot = -math.abs(normal:Dot(planeAxis))
	if dot == 0 then
		-- Parallel
		return point, 0
	end

	local dist = -rpoint:Dot(planeAxis) / dot
	return point + dist * normal, dist
end

function Geometry.getVolume(size: Vector3)
	return size.X * size.Y * size.Z
end

return Geometry