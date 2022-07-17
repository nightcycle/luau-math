
local types = require(script.Parent.Types)
export type Point = types.Point
export type Vertex = types.Vertex
export type Normal = types.Normal
export type Axis = types.Axis
export type Direction = types.Direction
export type Line = types.Line
export type Radian = types.Radian

local typeLerps = {} :: {[string]: (v1: any, v2: any, a: number) -> any}

function lerp(value1: any, value2: any, alpha: number):  any --written by CJ_Oyer, 2022
	assert(typeof(value1) == typeof(value2), "Type mismatch")
	assert(typeof(alpha) == "number", "Bad alpha")

	local solver = typeLerps[typeof(value1)] or function()
		return value1:Lerp(value2, alpha)
	end
	local result: any = solver(value1, value2, alpha)
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
				if typeof(seq) == "ColorSequence" then
					result = Color3.new(
						(next.Value.R - this.Value.R) * a + this.Value.R,
						(next.Value.G - this.Value.G) * a + this.Value.G,
						(next.Value.B - this.Value.B) * a + this.Value.B
					)
				elseif typeof(seq) == "NumberSequence" then
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
		return (v2 - v1)*alpha + v1
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
	["Color3"] = function(c1: Color3, c2: Color3, alpha: number)
		-- Converts a Color3 in RGB space to a Vector3 in Oklab space.
		local function to(rgb: Color3): Vector3
			local l = rgb.R * 0.4122214708 + rgb.G * 0.5363325363 + rgb.B * 0.0514459929
			local m = rgb.R * 0.2119034982 + rgb.G * 0.6806995451 + rgb.B * 0.1073969566
			local s = rgb.R * 0.0883024619 + rgb.G * 0.2817188376 + rgb.B * 0.6299787005

			local lRoot = l ^ (1/3)
			local mRoot = m ^ (1/3)
			local sRoot = s ^ (1/3)

			return Vector3.new(
				lRoot * 0.2104542553 + mRoot * 0.7936177850 - sRoot * 0.0040720468,
				lRoot * 1.9779984951 - mRoot * 2.4285922050 + sRoot * 0.4505937099,
				lRoot * 0.0259040371 + mRoot * 0.7827717662 - sRoot * 0.8086757660
			)
		end

		-- Converts a Vector3 in CIELAB space to a Color3 in RGB space.
		-- The Color3 will be clamped by default unless specified otherwise.
		local function from(lab: Vector3, unclamped: boolean?): Color3
			local lRoot = lab.X + lab.Y * 0.3963377774 + lab.Z * 0.2158037573
			local mRoot = lab.X - lab.Y * 0.1055613458 - lab.Z * 0.0638541728
			local sRoot = lab.X - lab.Y * 0.0894841775 - lab.Z * 1.2914855480

			local l = lRoot ^ 3
			local m = mRoot ^ 3
			local s = sRoot ^ 3

			local red = l * 4.0767416621 - m * 3.3077115913 + s * 0.2309699292
			local green = l * -1.2684380046 + m * 2.6097574011 - s * 0.3413193965
			local blue = l * -0.0041960863 - m * 0.7034186147 + s * 1.7076147010

			if not unclamped then
				red = math.clamp(red, 0, 1)
				green = math.clamp(green, 0, 1)
				blue = math.clamp(blue, 0, 1)
			end

			return Color3.new(red, green, blue)
		end
		local vec1 = to(c1)
		local vec2 = to(c2)
		return from(vec1:Lerp(vec2, alpha))
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
		local action = lerp(p1.Action, p2.Action, alpha)
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

-- Prescribed Material design Beziers and optimized Robert Penner functions
-- @rostrap EasingFunctions
-- @author Robert Penner

--[[
	Disclaimer for Robert Penner's Easing Equations license:

	TERMS OF USE - EASING EQUATIONS

	Open source under the BSD License.

	Copyright © 2001 Robert Penner
	All rights reserved.

	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

	* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
	* Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
	IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
	OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- For all easing functions:
-- t = elapsed time
-- b = beginning value
-- c = change in value same as: ending - beginning
-- d = duration (total time)

-- Where applicable
-- a = amplitude
-- p = period

local sin, cos, pi, abs, asin = math.sin, math.cos, math.pi, math.abs, math.asin
local _2pi = 2 * pi
local _halfpi = 0.5 * pi

local function outBounce(t, b, c, d): number
	t = t / d
	if t < 1 / 2.75 then
		return c * (7.5625 * t * t) + b
	elseif t < 2 / 2.75 then
		t = t - (1.5 / 2.75)
		return c * (7.5625 * t * t + 0.75) + b
	elseif t < 2.5 / 2.75 then
		t = t - (2.25 / 2.75)
		return c * (7.5625 * t * t + 0.9375) + b
	else
		t = t - (2.625 / 2.75)
		return c * (7.5625 * t * t + 0.984375) + b
	end
end

local function inBounce(t, b, c, d): number
	return c - outBounce(d - t, 0, c, d) + b
end

local EasingFunctions = {
	[Enum.EasingStyle.Sine] = {
		[Enum.EasingDirection.In] = function(t, b, c, d)
			return -c * cos(t / d * _halfpi) + c + b
		end,
		[Enum.EasingDirection.InOut] = function(t, b, c, d)
			return -c * 0.5 * (cos(pi * t / d) - 1) + b
		end,
		[Enum.EasingDirection.Out] = function(t, b, c, d)
			return c * sin(t / d * _halfpi) + b
		end
	},
	[Enum.EasingStyle.Quint] = {
		[Enum.EasingDirection.In] = function(t, b, c, d)
			t = t / d
			return c * t * t * t * t * t + b
		end,
		[Enum.EasingDirection.InOut] = function(t, b, c, d)
			t = t / d * 2
			if t < 1 then
				return c * 0.5 * t * t * t * t * t + b
			else
				t = t - 2
				return c * 0.5 * (t * t * t * t * t + 2) + b
			end
		end,
		[Enum.EasingDirection.Out] = function(t, b, c, d)
			t = t / d - 1
			return c * (t * t * t * t * t + 1) + b
		end
	},
	[Enum.EasingStyle.Quart] = {
		[Enum.EasingDirection.In] = function(t, b, c, d)
			t = t / d
			return c * t * t * t * t + b
		end,
		[Enum.EasingDirection.InOut] = function(t, b, c, d)
			t = t / d * 2
			if t < 1 then
				return c * 0.5 * t * t * t * t + b
			else
				t = t - 2
				return -c * 0.5 * (t * t * t * t - 2) + b
			end
		end,
		[Enum.EasingDirection.Out] = function(t, b, c, d)
			t = t / d - 1
			return -c * (t * t * t * t - 1) + b
		end
	},
	[Enum.EasingStyle.Quad] = {
		[Enum.EasingDirection.In] = function(t, b, c, d)
			t = t / d
			return c * t * t + b
		end,
		[Enum.EasingDirection.InOut] = function(t, b, c, d)
			t = t / d * 2
			return t < 1 and c * 0.5 * t * t + b or -c * 0.5 * ((t - 1) * (t - 3) - 1) + b
		end,
		[Enum.EasingDirection.Out] = function(t, b, c, d)
			t = t / d
			return -c * t * (t - 2) + b
		end
	},
	[Enum.EasingStyle.Linear] = {
		[Enum.EasingDirection.In] = function(t, b, c, d)
			return c * t / d + b
		end,
		[Enum.EasingDirection.InOut] = function(t, b, c, d)
			return c * t / d + b
		end,
		[Enum.EasingDirection.Out] = function(t, b, c, d)
			return c * t / d + b
		end
	},
	[Enum.EasingStyle.Exponential] = {
		[Enum.EasingDirection.In] = function(t, b, c, d)
			return t == 0 and b or c * 2 ^ (10 * (t / d - 1)) + b - c * 0.001
		end,
		[Enum.EasingDirection.InOut] = function(t, b, c, d)
			t = t / d * 2
			return t == 0 and b or t == 2 and b + c or t < 1 and c * 0.5 * 2 ^ (10 * (t - 1)) + b - c * 0.0005 or c * 0.5 * 1.0005 * (2 - 2 ^ (-10 * (t - 1))) + b
		end,
		[Enum.EasingDirection.Out] = function(t, b, c, d)
			return t == d and b + c or c * 1.001 * (1 - 2 ^ (-10 * t / d)) + b
		end
	},
	[Enum.EasingStyle.Elastic] = {
		[Enum.EasingDirection.In] = function(t, b, c, d)
			t = t / d - 1
			local a = 1
			local p = d * 0.3
			return t == -1 and b or t == 0 and b + c or (not a or a < abs(c)) and -(c * 2 ^ (10 * t) * sin((t * d - p * .25) * _2pi / p)) + b or -(a * 2 ^ (10 * t) * sin((t * d - p / _2pi * asin(c/a)) * _2pi / p)) + b
		end,
		[Enum.EasingDirection.InOut] = function(t, b, c, d)
			if t == 0 then
				return b
			end
		
			t = t / d * 2 - 1
		
			if t == 1 then
				return b + c
			end
		
			local a = 1
			local p = d * 0.3
		
			local s
		
			if not a or a < abs(c) then
				a = c
				s = p * .25
			else
				s = p / _2pi * asin(c / a)
			end
		
			if t < 1 then
				return -0.5 * a * 2 ^ (10 * t) * sin((t * d - s) * _2pi / p) + b
			else
				return a * 2 ^ (-10 * t) * sin((t * d - s) * _2pi / p ) * 0.5 + c + b
			end
		end,
		[Enum.EasingDirection.Out] = function(t, b, c, d)
			t = t / d
			local a = 1
			local p = d * 0.3
			return t == 0 and b or t == 1 and b + c or (not a or a < abs(c)) and c * 2 ^ (-10 * t) * sin((t * d - p * .25) * _2pi / p) + c + b or a * 2 ^ (-10 * t) * sin((t * d - p / _2pi * asin(c / a)) * _2pi / p) + c + b
		end
	},
	[Enum.EasingStyle.Cubic] = {
		[Enum.EasingDirection.In] = function(t, b, c, d)
			t = t / d
			return c * t * t * t + b
		end,
		[Enum.EasingDirection.InOut] = function(t, b, c, d)
			t = t / d * 2
			if t < 1 then
				return c * 0.5 * t * t * t + b
			else
				t = t - 2
				return c * 0.5 * (t * t * t + 2) + b
			end
		end,
		[Enum.EasingDirection.Out] = function(t, b, c, d)
			t = t / d - 1
			return c * (t * t * t + 1) + b
		end
	},
	[Enum.EasingStyle.Circular] = {
		[Enum.EasingDirection.In] = function(t, b, c, d)
			t = t / d
			return -c * ((1 - t * t) ^ 0.5 - 1) + b
		end,
		[Enum.EasingDirection.InOut] = function(t, b, c, d)
			t = t / d * 2
			if t < 1 then
				return -c * 0.5 * ((1 - t * t) ^ 0.5 - 1) + b
			else
				t = t - 2
				return c * 0.5 * ((1 - t * t) ^ 0.5 + 1) + b
			end
		end,
		[Enum.EasingDirection.Out] = function(t, b, c, d)
			t = t / d - 1
			return c * (1 - t * t) ^ 0.5 + b
		end
	},
	[Enum.EasingStyle.Bounce] = {
		[Enum.EasingDirection.In] = inBounce,
		[Enum.EasingDirection.InOut] = function(t, b, c, d)
			if t < d * 0.5 then
				return inBounce(t * 2, 0, c, d) * 0.5 + b
			else
				return outBounce(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b
			end
		end,
		[Enum.EasingDirection.Out] = outBounce,
	},
	[Enum.EasingStyle.Back] = {
		[Enum.EasingDirection.In] = function(t, b, c, d)
			local s = 1.70158
			t = t / d
			return c * t * t * ((s + 1) * t - s) + b
		end,
		[Enum.EasingDirection.InOut] = function(t, b, c, d)
			local s = 1.70158 * 1.525
			t = t / d * 2
			if t < 1 then
				return c * 0.5 * (t * t * ((s + 1) * t - s)) + b
			else
				t = t - 2
				return c * 0.5 * (t * t * ((s + 1) * t + s) + 2) + b
			end
		end,
		[Enum.EasingDirection.Out] = function(t, b, c, d)
			local s = 1.70158
			t = t / d - 1
			return c * (t * t * ((s + 1) * t + s) + 1) + b
		end
	},
}

local Algebra = {
	lerp = function(a: any, b: any, alpha: number) : any
		return lerp(a, b, alpha)
	end,
	ease = function(alpha: number, easingStyle: EnumItem, easingDirection: EnumItem)
		easingStyle = easingStyle or Enum.EasingStyle.Quad
		easingDirection = easingDirection or Enum.EasingDirection.InOut
		return EasingFunctions[easingStyle][easingDirection](alpha, 0, 1, 1)
	end,
	bezier = function(...)
		local allPoints: {[number]: Vector3 | Vector2} = {...}
		local function solve(alpha: number, points: {[number]: Vector2 | Vector3})
			local newPoints = {}
			for i=1, #points - 1 do
				local a = points[i]
				local b = points[i+1]
				table.insert(newPoints, lerp(a, b, alpha))
			end
			if #newPoints <= 1 then
				return newPoints[1]
			else
				return solve(alpha, newPoints)
			end
		end

		return function(alpha)
			return solve(alpha, allPoints)
		end
	end,
	Vector = require(script:WaitForChild("Vector")),
	Matrix = require(script:WaitForChild("Matrix")),
}

return Algebra