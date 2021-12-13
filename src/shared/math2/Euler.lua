local euler = {}

function euler.eulerDistance(radA, radB)
	if radA == radB then return 0 end

	if radA < math.rad(-90) and radB > math.rad(90) then
		local r1 = radA + math.rad(360)
		return r1 - radB
	else
		return radB - radA
	end
end

function euler.eulerDistanceV2(aRadV2, bRadV2)
	local aX = aRadV2.X
	local bX = bRadV2.X
	local x = euler.eulerDistance(aX, bX)
	local aY = aRadV2.Y
	local bY = bRadV2.Y
	local y = euler.eulerDistance(aY, bY)
	return Vector2.new(x,y).Magnitude
end

return euler