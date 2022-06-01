
local typeLerps = {} :: {[string]: (v1: any, v2: any, a: number) -> any}

function lerp(value1: any, value2: any, alpha: number):  any --written by CJ_Oyer, 2022
	assert(typeof(value1) == typeof(value2), "Type mismatch")
	assert(typeof(alpha) == "number", "Bad alpha")

	local solver = typeLerps[typeof(value1)] or function() 
		return value1:Lerp(value2, alpha)
	end
	local result: any = solver()
	return result
end

function sequence(seq1: NumberSequence | ColorSequence, seq2: NumberSequence | ColorSequence, alpha: number): NumberSequence | ColorSequence

	local values = {}
	local envelopes = {}

	local function eval(seq: ColorSequence | NumberSequence, keyT: number)
		if keyT == 0 then return seq.Keypoints[1].Value end
		if keyT == 1 then return seq.Keypoints[#seq.Keypoints].Value end
		-- Step through each sequential pair of keypoints and see if alpha
		-- lies between the points' time values.
		local result
		for i = 1, #seq.Keypoints - 1 do
			local this = seq.Keypoints[i]
			local next = seq.Keypoints[i + 1]
			if keyT >= this.Time and keyT < next.Time then
				-- Calculate how far alpha lies between the points
				local a = (keyT - this.Time) / (next.Time - this.Time)
				-- Evaluate the real value between the points using alpha
				if typeof(s) == "ColorSequence" then
					result = Color3.new(
						(next.Value.R - this.Value.R) * a + this.Value.R,
						(next.Value.G - this.Value.G) * a + this.Value.G,
						(next.Value.B - this.Value.B) * a + this.Value.B
					)
				elseif typeof(s) == "NumberSequence" then
					result = (next.Value - this.Value) * a + this.Value
				end
				break
			end
		end
		return result
	end
	
	-- fill in gaps in keypoint sequences
	for i, kp in ipairs(seq1.Keypoints) do
		if typeof((seq1)) == "NumberSequence" then
			envelopes[kp.Time] = {kp.Envelope, eval(seq2, kp.Time)}
		end
		values[kp.Time] = {kp.Value, eval(seq2, kp.Time)}
	end
	for i, kp in ipairs(seq2.Keypoints) do
		if typeof((seq1)) == "NumberSequence" then
			if envelopes[kp.Time] then
				envelopes[kp.Time][2] = kp.Envelope
			else
				local _, env = eval(seq1, kp.Time)
				envelopes[kp.Time] = {env, kp.Envelope}
			end
		end
		if values[kp.Time] then
			values[kp.Time][2] = kp.Value
		else
			values[kp.Time] = {eval(seq1, kp.Time), kp.Value}
		end
	end
	-- sort the keypoint data
	local order = {}
	for t, vList in pairs(values) do table.insert(order, t) end
	table.sort(order, function(a,b)
		return a < b
	end)

	-- assemble final set of keypoints
	local final = {}
	for i, t in ipairs(order) do
		local vList = values[t]
		local newKeypoint
		if typeof(seq1) == "NumberSequence" then
			local eList = envelopes[t]
			newKeypoint = NumberSequenceKeypoint.new(t,
				lerp(vList[1], vList[2], alpha),
				lerp(eList[1], eList[2], alpha)
			)
		else
			if typeof(seq1) == "NumberSequence" then
				newKeypoint = NumberSequenceKeypoint.new(t, lerp(vList[1], vList[2], alpha))
			elseif typeof(seq1) == "ColorSequence" then
				newKeypoint = ColorSequenceKeypoint.new(t, lerp(vList[1], vList[2], alpha))
			end
		end
		
		table.insert(final, newKeypoint)
	end
	local finalSequence: NumberSequence | ColorSequence
	if typeof(seq1) == "NumberSequence" then
		finalSequence = NumberSequence.new(final)
	elseif typeof(seq1) == "ColorSequence" then
		finalSequence = ColorSequence.new(final)
	end
	return finalSequence
end


typeLerps = {
	["number"] = function(v1: number, v2: number, alpha: number): number
		return (v1 - v1)*alpha + v1 
	end,
	["string"] = function(s1: string, s2: string, alpha: number): string
		local len = math.max(string.len(s1), string.len(s2))
		local progress = math.ceil(len*alpha)
		if progress == len then return s2 end
		local start = string.sub(s2, 1, progress)
		local finish = string.sub(s1, progress, math.max(progress, string.len(s1)))
		if string.len(finish) < string.len(start) and progress > string.len(start) then
			finish = string.rep(" ", progress - string.len(start)-1)..finish
		end
		return start..finish
	end,
	["boolean"] = function(v1: boolean, v2: boolean, alpha: number): boolean
		if alpha >= 0.5 then
			return v1
		else
			return v2
		end 
	end,
	["BrickColor"] = function(b1: BrickColor, b2: BrickColor, alpha: number): BrickColor
		local c1: Color3 = Color3.new(b1.r, b1.g, b1.b)
		local c2: Color3 = Color3.new(b2.r, b2.g, b2.b)
		return BrickColor.new(c1:Lerp(c2, alpha))
	end,
	["ColorSequence"] = function(c1: ColorSequence, c2: ColorSequence, alpha: number): ColorSequence
		local result = sequence(c1, c2, alpha)
		assert(typeof(result) == "ColorSequence", "Bad ColorSequence")
		return result
	end,
	["NumberSequence"] = function(n1: NumberSequence, n2: NumberSequence, alpha: number): NumberSequence
		local result = sequence(n1, n2, alpha)
		assert(typeof(result) == "NumberSequence", "Bad NumberSequence")
		return result
	end,
	["ColorSequenceKeypoint"] = function(k1: ColorSequenceKeypoint, k2: ColorSequenceKeypoint, alpha: number): ColorSequenceKeypoint
		local kTime: number = lerp(k1.Time, k2.Time, alpha)
		local kValue: Color3 = lerp(k1.Value, k2.Value, alpha)

		return ColorSequenceKeypoint.new(
			kTime,
			kValue
		)
	end,
	["NumberSequenceKeypoint"] = function(k1: NumberSequenceKeypoint, k2: NumberSequenceKeypoint, alpha: number): NumberSequenceKeypoint
		local kTime: number = lerp(k1.Time, k2.Time, alpha)
		local kValue: number = lerp(k1.Value, k2.Value, alpha)
		return NumberSequenceKeypoint.new(
			kTime,
			kValue
		)
	end,
	["DateTime"] = function(d1: DateTime, d2: DateTime, alpha: number): DateTime
		local unix1 = d1.UnixTimestampMillis
		local unix2 = d2.UnixTimestampMillis
		return DateTime.fromUnixTimestampMillis(lerp(unix1, unix2, alpha))
	end,
	["EnumItem"] = function(e1: EnumItem, e2: EnumItem, alpha: number): EnumItem
		assert(e1.EnumType == e2.EnumType, "EnumType mismatch")
		local enumType = e1.EnumType
		local otherEnums = enumType:GetEnumItems()
		local final = math.clamp(math.round(lerp(e1.Value, e2.Value, alpha)), 0, #otherEnums-1)
		return otherEnums[final+1]
	end,
	["NumberRange"] = function(n1: NumberRange, n2: NumberRange, alpha: number): NumberRange
		local min = lerp(n1.Min, n2.Min, alpha)
		local max = lerp(n1.Max, n2.Max, alpha)
		return NumberRange.new(
			min,
			max
		)
	end,
	["PathWaypoint"] = function(p1:PathWaypoint, p2:PathWaypoint, alpha: number): PathWaypoint
		local position: Vector3 = lerp(p1.Position, p2.Position, alpha)
		local action: EnumPathWaypointAction = lerp(p1.Action, p2.Action, alpha)
		return PathWaypoint.new(position, action)
	end,
	["PhysicalProperties"] = function(p1 : PhysicalProperties, p2 : PhysicalProperties, alpha: number): PhysicalProperties	
		local density: number = lerp(p1.Density, p2.Density, alpha)
		local friction: number = lerp(p1.Friction, p2.Friction, alpha)
		local elasticity: number = lerp(p1.Elasticity, p2.Elasticity, alpha)
		local frictionWeight: number = lerp(p1.FrictionWeight, p2.FrictionWeight, alpha)
		local elasticWeight: number = lerp(p1.ElasticityWeight, p2.ElasticityWeight, alpha)
		
		return PhysicalProperties.new(density, friction, elasticity, frictionWeight, elasticWeight)
	end,
	["Ray"] = function(ray1: Ray, ray2: Ray, alpha: number): Ray

		local origin: Vector3 = lerp(ray1.Origin, ray2.Origin, alpha)
		local direction: Vector3 = lerp(ray1.Direction, ray2.Direction, alpha)

		return Ray.new(origin, direction)
	end,
	["Rect"] = function(rect1: Rect, rect2: Rect, alpha: number): Rect
		local min: Vector2 = lerp(rect1.Min, rect2.Min, alpha)
		local max: Vector2 = lerp(rect1.Max, rect2.Max, alpha)

		return Rect.new(min, max)
	end,
	["Region3"] = function(r1: Region3, r2: Region3, alpha: number)
		local min1: Vector3 = (r1.CFrame * CFrame.new(-r1.Size*0.5/2)).Position
		local min2: Vector3 = (r2.CFrame * CFrame.new(-r2.Size*0.5/2)).Position

		local max1: Vector3 = (r1.CFrame * CFrame.new(r1.Size*0.5/2)).Position
		local max2: Vector3 = (r2.CFrame * CFrame.new(r2.Size*0.5/2)).Position

		local min: Vector3 = lerp(min1, min2, alpha)
		local max: Vector3 = lerp(max1, max2, alpha)

		return Region3.new(min, max)
	end,
	["Region3int16"] = function(r1: Region3int16, r2: Region3int16, alpha: number)
		local min: Vector3 = lerp(r1.Min, r2.Min, alpha)
		local max: Vector3 = lerp(r1.Max, r2.Max, alpha)

		return Region3.new(min, max)
	end,
	["UDim"] = function(u1: UDim, u2: UDim, alpha: number)
		local scale = lerp(u1.Scale, u2.Scale, alpha)
		local offset = lerp(u1.Offset, u2.Offset, alpha)
		return UDim.new(scale, offset)
	end,
	["UDim2"] = function(u1: UDim2, u2: UDim2, alpha: number)
		local x: UDim = lerp(u1.X, u2.X, alpha)
		local y: UDim = lerp(u1.Y, u2.Y, alpha)
		return UDim2.new(x, y)
	end,
}


local Algebra = {
	lerp = function(a: any, b: any, alpha: number) : any
		return lerp(a, b, alpha)
	end
}

return Algebra