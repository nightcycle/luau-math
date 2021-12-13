local trigonometry = {}

function trigonometry.lawOfCos(a, b, c) --gamma = ab angle
	local numerator = (a^2) + (b^2) - (c^2)
	local denominator = (2*a*b)

	return math.acos(numerator/denominator)


end

return trigonometry