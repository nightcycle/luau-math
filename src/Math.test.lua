--!strict
export type Test = () -> boolean
export type CheckList = () -> {[string]: Test | CheckList}

local types = require(script.Parent.Types)
type Point = types.Point
type Vertex = types.Vertex
type Normal = types.Normal
type Axis = types.Axis
type Direction = types.Direction
type Line = types.Line
type Surface = types.Surface
type Radian = types.Radian
type Degree = types.Degree
type Face = types.Face
type Roundable = types.Roundable

return function()

	return {
		["Algebra"] = function()
			local Alg = require(script.Parent:WaitForChild("Algebra"))
			return {
				["Lerp"] = function()
					local Lerp = Alg.lerp
					local alpha = 0.5
					return {
						["Vector2"] = function()
							local a = Vector2.new(0,0)
							local b = Vector2.new(1,1)
							local v = Lerp(a,b, alpha)
							return v == Vector2.new(0.5,0.5)
						end :: Test,
						["String"] = function()
							local a = "Apple"
							local b = "Banana"
							local v = Lerp(a,b,alpha)
							return v == "Banple"
						end :: Test,
					}
				end :: CheckList,
			}
		end :: CheckList,
		["Geometry"] = function()
			local Geometry = require(script.Parent:WaitForChild("Geometry"))
			local a: Vertex = Vector3.new(0,2,0)
			local b: Vertex = Vector3.new(1,0,0)
			local c: Vertex = Vector3.new(0,0,4)
			local d: Vertex = Vector3.new(0,2,4)

			local ab: Line = {a,b}
			local bc: Line = {b,c}
			local ca: Line = {c,a}
			local cd: Line = {c,d}
			local da: Line = {d,a}

			return {	
				getLineLength = function()
					return Geometry.getLineLength(cd) == cd.Magnitude
				end :: Test,
				getLineLengths = function()
					local daLen: number = Geometry.getLineLength(da)
					local cdLen: number = Geometry.getLineLength(cd)
					local fullLen = 0 
					for i, len in pairs(Geometry.getLineLength({cd, da})) do
						fullLen += len
					end
					return daLen + cdLen == fullLen
				end :: Test,
				getLineCenter = function()
					return false
				end :: Test,
				getLineCenters = function()
					return false
				end :: Test,
				getLineAxis = function()
					return false
				end :: Test,
				getLineAxes = function()
					return false
				end :: Test,
				getIfVerticesConnected = function()
					return false
				end :: Test,
				getConnectedVertices = function()
					return false
				end :: Test,
				getAllVerticesFromLines = function()
					return false
				end :: Test,
				getAllVertexConnectionsFromLines = function()
					return false
				end :: Test,
				getSharedVertex = function()
					return false
				end :: Test,
				getIfRightAngle = function()
					return false
				end :: Test,
				getIfRightAngleFromVertices = function()
					return false
				end :: Test,
				getRightAngleVertices = function()
					return false
				end :: Test,
				getIntersectionBetweenTwoLines = function()
					return false
				end :: Test,
				getVertexOppositePointsFromLines = function()
					return false
				end :: Test,
				getDiagonalLinesFromEdges = function()
					return false
				end :: Test,
				getTrianglePerimeter = function()
					return false
				end :: Test,
				getTriangleArea = function()
					return false
				end :: Test,
				getIfPointIsInTriangle = function()
					return false
				end :: Test,
				getAngleThroughLawOfCos = function()
					return false
				end :: Test,
				getAngleBetweenTwoLines = function()
					return false
				end :: Test,
				getSideLengthThroughLawOfCos = function()
					return false
				end :: Test,
				getLineInwardNormal = function()
					return false
				end :: Test,
				getClosestPointInList = function()
					return false
				end :: Test,
				getFarthestPointInList = function()
					return false
				end :: Test,
				getClosestPointOnLine = function()
					return false
				end :: Test,
				getLineClosestToPoint = function()
					return false
				end :: Test,
				getCenterFromLines = function()
					return false
				end :: Test,
				getSurfaceCFrameFromLines = function()
					return false
				end :: Test,
				getBoxBoundaries = function()
					return false
				end :: Test,
				getPlaneIntersection = function()
					return false
				end :: Test,
				getVolume = function()
					return false
				end :: Test,
			}
		end :: CheckList,
	}
end :: CheckList