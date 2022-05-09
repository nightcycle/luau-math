local Algebra = {}

function lerp(value1: any, value2: any, alpha: number)
	--written by CJ_Oyer, 2022
	assert(typeof(value1) == typeof(value2), "Type mismatch")
	assert(typeof(alpha) == "number", "Bad alpha")
	local function instLerp(final, properties)
		for i, k in ipairs(properties) do
			pcall(function()
				final[k] = lerp(value1[k], value2[k], alpha)
			end)
		end
		return final
	end
	local function evalCS(cs, t) --determines color at time on ColorSequence
		-- If we are at 0 or 1, return the first or last value respectively
		if t == 0 then return cs.Keypoints[1].Value end
		if t == 1 then return cs.Keypoints[#cs.Keypoints].Value end
		-- Step through each sequential pair of keypoints and see if alpha
		-- lies between the points' time values.
		for i = 1, #cs.Keypoints - 1 do
			local this = cs.Keypoints[i]
			local next = cs.Keypoints[i + 1]
			if t >= this.Time and t < next.Time then
				-- Calculate how far alpha lies between the points
				local a = (t - this.Time) / (next.Time - this.Time)
				-- Evaluate the real value between the points using alpha
				return Color3.new(
					(next.Value.R - this.Value.R) * a + this.Value.R,
					(next.Value.G - this.Value.G) * a + this.Value.G,
					(next.Value.B - this.Value.B) * a + this.Value.B
				)
			end
		end
	end
	local function evalNS(ns, t)
		-- If we are at 0 or 1, return the first or last value respectively
		if t == 0 then return ns.Keypoints[1].Value end
		if t == 1 then return ns.Keypoints[#ns.Keypoints].Value end
		-- Step through each sequential pair of keypoints and see if alpha
		-- lies between the points' time values.
		for i = 1, #ns.Keypoints - 1 do
			local this = ns.Keypoints[i]
			local next = ns.Keypoints[i + 1]
			if t >= this.Time and t < next.Time then
				-- Calculate how far alpha lies between the points
				local a = (t - this.Time) / (next.Time - this.Time)
				-- Evaluate the real value between the points using alpha
				return (next.Value - this.Value) * a + this.Value, (next.Envelope - this.Envelope) * a + this.Envelope
			end
		end
	end

	local function sequence(eval, sClass, kClass, hasEnvelope: boolean)
		local k1 = value1.Keypoints
		local k2 = value2.Keypoints
		local values = {}
		local envelopes = {}
		
		-- fill in gaps in keypoint sequences
		for i, kp in ipairs(k1) do
			if hasEnvelope then
				envelopes[kp.Time] = {kp.Envelope, eval(value2, kp.Time)}
			end
			values[kp.Time] = {kp.Value, eval(value2, kp.Time)}
		end
		for i, kp in ipairs(k2) do
			if hasEnvelope then
				if envelopes[kp.Time] then
					envelopes[kp.Time][2] = kp.Envelope
				else
					local v, env = eval(value1, kp.Time)
					envelopes[kp.Time] = {env, kp.Envelope}
				end
			end
			if values[kp.Time] then
				values[kp.Time][2] = kp.Value
			else
				values[kp.Time] = {eval(value1, kp.Time), kp.Value}
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
			if hasEnvelope then
				local eList = envelopes[t]
				newKeypoint = kClass.new(t,
				lerp(vList[1], vList[2], alpha),
				lerp(eList[1], eList[2], alpha)
			)
			else
				newKeypoint = kClass.new(t, lerp(vList[1], vList[2], alpha))
			end
			
			table.insert(final, newKeypoint)
		end
		return sClass.new(final)
	end
	local types = {
		["number"] = function() return (value2 - value1)*alpha + value1 end,
		["string"] = function()
			local len = math.max(string.len(value1), string.len(value2))
			local progress = math.ceil(len*alpha)
			if progress == len then return value2 end
			local start = string.sub(value2, 1, progress)
			local finish = string.sub(value1, progress, math.max(progress, string.len(value1)))
			if string.len(finish) < string.len(start) and progress > string.len(start) then
				finish = string.rep(" ", progress - string.len(start)-1)..finish
			end
			return start..finish
		end,
		["boolean"] = function() if alpha >= 0.5 then return value2 else return value1 end end,
		["BrickColor"] = function()
			local c1 = Color3.new(value1.r, value1.g, value1.b)
			local c2 = Color3.new(value2.r, value2.g, value2.b)
			return BrickColor.new(c1:Lerp(c2, alpha))
		end,
		["ColorSequence"] = function()
			return sequence(evalCS, ColorSequence, ColorSequenceKeypoint, false)
		end,
		["ColorSequenceKeypoint"] = function()
			return ColorSequenceKeypoint.new(
				lerp(value1.Time, value2.Time, alpha),
				lerp(value1.Value, value2.Value, alpha)
			)
		end,
		["DateTime"] = function()
			local unix1 = value1.UnixTimestampMillis
			local unix2 = value2.UnixTimestampMillis
			return DateTime.fromUnixTimestampMillis(lerp(unix1, unix2, alpha))
		end,
		["EnumItem"] = function()
			assert(value1.EnumType == value2.EnumType, "EnumType mismatch")
			local enumType = value1.EnumType
			local otherEnums = enumType:GetEnumItems()
			local final = math.clamp(math.round(lerp(value1.Value, value2.Value, alpha)), 0, #otherEnums-1)
			return otherEnums[final+1]
		end,
		["NumberRange"] = function()
			return NumberRange.new(
				lerp(value1.Min, value2.Min, alpha),
				lerp(value1.Max, value2.Max, alpha)
			)
		end,
		["NumberSequence"] = function()
			return sequence(evalNS, NumberSequence, NumberSequenceKeypoint, true)
		end,
		["PathWaypoint"] = function()
			local final = PathWaypoint.new()
			instLerp(final, {"Action", "Position", "Label"})
		end,
		["PhysicalProperties"] = function()
			local final = PhysicalProperties.new()
			instLerp(final, {"Friction", "Density", "Elasticity", "FrictionWeight", "ElasticityWeight"})
		end,
		["Ray"] = function()
			local final = Ray.new()
			instLerp(final, {"Origin", "Direction"})
		end,
		["Rect"] = function()
			local final = Rect.new()
			instLerp(final, {"Width", "Height", "Min", "Max"})
		end,
		["Region3"] = function()
			local final = Region3.new()
			instLerp(final, {"CFrame", "Size"})
		end,
		["Region3int16"] = function()
			local final = Region3int16.new()
			instLerp(final, {"CFrame", "Size"})
		end,
		["UDim"] = function()
			local final = UDim.new()
			instLerp(final, {"Scale", "Offset"})
		end,
		["UDim2"] = function()
			local final = UDim.new()
			instLerp(final, {"X", "Y"})
		end,
	}
	local solver = types[typeof(value1)] or function () return value1:Lerp(value2, alpha) end
	return solver()
end

Algebra.lerp = lerp

return Algebra