--!strict

-- Prescribed Material design Beziers and optimized Robert Penner functions
-- @CJ_Oyer reformated for this library
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

local EasingFunctions: {[Enum.EasingStyle]: {[Enum.EasingDirection]: ((t: number, b: number, c: number, d: number) -> number)}} = {
	[Enum.EasingStyle.Sine] = {
		[Enum.EasingDirection.In] = function(t, b, c, d)
			return -c * cos(t / d * _halfpi) + c + b
		end,
		[Enum.EasingDirection.InOut] = function(t, b, c, d)
			return -c * 0.5 * (cos(pi * t / d) - 1) + b
		end,
		[Enum.EasingDirection.Out] = function(t, b, c, d)
			return c * sin(t / d * _halfpi) + b
		end,
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
		end,
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
		end,
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
		end,
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
		end,
	},
	[Enum.EasingStyle.Exponential] = {
		[Enum.EasingDirection.In] = function(t, b, c, d)
			return t == 0 and b or c * 2 ^ (10 * (t / d - 1)) + b - c * 0.001
		end,
		[Enum.EasingDirection.InOut] = function(t, b, c, d)
			t = t / d * 2
			if t == 0 then return b end
			if t == d then return b + c end
			t = t / d * 2
			if t < 1 then
			  return c / 2 * math.pow(2, 10 * (t - 1)) + b - c * 0.0005
			else
			  t = t - 1
			  return c / 2 * 1.0005 * (-math.pow(2, -10 * t) + 2) + b
			end
		end,
		[Enum.EasingDirection.Out] = function(t, b, c, d)
			return t == d and b + c or c * 1.001 * (1 - 2 ^ (-10 * t / d)) + b
		end,
	},
	[Enum.EasingStyle.Elastic] = {
		[Enum.EasingDirection.In] = function(t, b, c, d)
			if t == 0 then return b end

			t = t / d
		   
			if t == 1  then return b + c end
			
			local p2 = 1
			if not p2 then p2 = d * 0.3 end
		   
			local s
		   
			local a2 = 1
			if not a2 or a2 < abs(c) then
			  a2 = c
			  s = p2 / 4
			else
			  s = p2 / (2 * pi) * asin(c/a2)
			end
		   
			t = t - 1
		   
			return -(a2 * math.pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p2)) + b
		end,
		[Enum.EasingDirection.InOut] = function(t, b, c, d)
			if t == 0 then
				return b
			end

			t = t / d * 2 - 1

			if t == 1 then
				return b + c
			end

			local a2 = 1
			local p2 = d * 0.3

			local s

			if not a2 or a2 < abs(c) then
				a2 = c
				s = p2 * 0.25
			else
				s = p2 / _2pi * asin(c / a2)
			end

			if t < 1 then
				return -0.5 * a2 * 2 ^ (10 * t) * sin((t * d - s) * _2pi / p2) + b
			else
				return a2 * 2 ^ (-10 * t) * sin((t * d - s) * _2pi / p2) * 0.5 + c + b
			end
		end,
		[Enum.EasingDirection.Out] = function(t, b, c, d)
			if t == 0 then return b end

			t = t / d
		   
			if t == 1 then return b + c end
		   
			local p2 = 1
			local a2 = 1

			if not p2 then p2 = d * 0.3 end
		   
			local s
		   
			if not a2 or a2 < abs(c) then
				a2 = c
			  s = p2 / 4
			else
			  s = p2 / (2 * pi) * asin(c/a2)
			end
		   
			return a2 * math.pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p2) + c + b
		end,
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
		end,
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
		end,
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
		end,
	},
}

return function(alpha: number, easingStyle: Enum.EasingStyle, easingDirection: Enum.EasingDirection)
	easingStyle = easingStyle or Enum.EasingStyle.Quad
	easingDirection = easingDirection or Enum.EasingDirection.InOut
	return EasingFunctions[easingStyle][easingDirection](alpha, 0, 1, 1)
end