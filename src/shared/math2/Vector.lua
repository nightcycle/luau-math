local vector = {}

function vector.filterNormal(vec, norm)
	local weight = math.abs(vec.Unit:Dot(norm))
	local normal = vec.Unit
	local antiAxisNormal = norm * weight
	local finalNormal = (normal - antiAxisNormal).Unit
	local finalMagnitude = vec.Magnitude * (1 - math.abs(weight))
	return finalNormal * finalMagnitude
end

function vector.filterAxis(vec, axis)
	return vector.filterNormal(vector.filterNormal(vec, -axis), axis)
end

function vector.fuzzyEq(a, b, precision)
	precision = precision or 0
	local same = true
	local rounding = 10^precision
	local xSame = math.round(a.X*rounding) == math.round(b.X*rounding)
	local ySame = math.round(a.Y*rounding) == math.round(b.Y*rounding)
	local zSame = math.round(a.Z*rounding) == math.round(b.Z*rounding)
	return xSame and ySame and zSame
end

function vector.getAngleBetween(a:Vector3, b:Vector3)
	local trigonometry = require(script.Parent:WaitForChild("Trigonometry"))
	local c = a-b
	local angle = trigonometry.lawOfCos(a.Magnitude, b.Magnitude, c.Magnitude)
	if angle ~= angle then
		return 0
	else
		return angle
	end
end

return vector