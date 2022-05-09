local Math = {}
function Math:__index(k)
	if rawget(Math, k) then
		return rawget(Math, k)
	else
		return math[k]
	end
end

--[[
	@startuml
	!theme crt-amber
	interface Math {
		+ round(value: number, weight: number | nil)
	}
	@enduml
]]--


function Math.round(v, weight)
	weight = weight or 1
	if typeof(v) == "number" then
		return math.round(v/weight)*weight
	elseif typeof(v) == "Vector2" then
		return Vector2.new(
			Math.round(v.X, weight),
			Math.round(v.Y, weight)
		)
	elseif typeof(v) == "Vector3" then
		return Vector3.new(
			Math.round(v.X, weight),
			Math.round(v.Y, weight),
			Math.round(v.Z, weight)
		)
	elseif typeof(v) == "Color3" then
		return Color3.new(
			Math.round(v.R, weight),
			Math.round(v.G, weight),
			Math.round(v.B, weight)
		)
	elseif typeof(v) == "CFrame" then
		return CFrame.fromMatrix(
			Math.round(v.Position, weight),
			Math.round(v.XVector, weight),
			Math.round(v.YVector, weight),
			Math.round(v.ZVector, weight)
		)
	end
end

Math.Geometry = require(script:WaitForChild("Geometry"))
Math.Mesh = require(script:WaitForChild("Mesh"))
Math.Matrix =  require(script:WaitForChild("Matrix"))
Math.Vector = require(script:WaitForChild("Vector"))
Math.Algebra = require(script:WaitForChild("Algebra"))

return setmetatable({}, Math)