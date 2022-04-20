-- Prescribed Material design Beziers and optimized Robert Penner functions
-- @rostrap EasingFunctions
-- @author Robert Penner

local Easing = {isInitialized = false}

local mutual

local Bezier

local Sharp
local Standard
local Acceleration
local Deceleration

--[[
	@startuml
	!theme crt-amber
	interface Easing {
		get(style: string, alpha: number): number
	}
	@enduml
]]--


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
local SoftSpringpi = -3.2*pi
local Springpi = 2*SoftSpringpi

function Easing.get(k, alpha)
	return Easing[k](alpha, 0, 1, 1)
end

function Easing.linear(t, b, c, d)
	return c * t / d + b
end

function Easing.smooth(t, b, c, d)
	t = t / d
	return c * t * t * (3 - 2*t) + b
end

function Easing.smoother(t, b, c, d)
	t = t / d
	return c*t*t*t * (t * (6*t - 15) + 10) + b
end

-- Arceusinator's Easing Functions
function Easing.revBack(t, b, c, d)
	t = 1 - t / d
	return c*(1 - (sin(t*_halfpi) + (sin(t*pi) * (cos(t*pi) + 1)*0.5))) + b
end

function Easing.ridiculousWiggle(t, b, c, d)
	t = t / d
	return c*sin(sin(t*pi)*_halfpi) + b
end

-- YellowTide's Easing Functions
function Easing.spring(t, b, c, d)
	t = t / d
	return (1 + (-2.72^(-6.9*t) * cos(Springpi*t))) * c + b
end

function Easing.softSpring(t, b, c, d)
	t = t / d
	return (1 + (-2.72^(-7.5*t) * cos(SoftSpringpi*t))) * c + b
end
-- End of YellowTide's functions

function Easing.inQuad(t, b, c, d)
	t = t / d
	return c * t * t + b
end

function Easing.outQuad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end

function Easing.inOutQuad(t, b, c, d)
	t = t / d * 2
	return t < 1 and c * 0.5 * t * t + b or -c * 0.5 * ((t - 1) * (t - 3) - 1) + b
end

function Easing.outInQuad(t, b, c, d)
	if t < d * 0.5 then
		t = 2 * t / d
		return -0.5 * c * t * (t - 2) + b
	else
		t, c = ((t * 2) - d) / d, 0.5 * c
		return c * t * t + b + c
	end
end

function Easing.inCubic(t, b, c, d)
	t = t / d
	return c * t * t * t + b
end

function Easing.outCubic(t, b, c, d)
	t = t / d - 1
	return c * (t * t * t + 1) + b
end

function Easing.inOutCubic(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c * 0.5 * t * t * t + b
	else
		t = t - 2
		return c * 0.5 * (t * t * t + 2) + b
	end
end

function Easing.outInCubic(t, b, c, d)
	if t < d * 0.5 then
		t = t * 2 / d - 1
		return c * 0.5 * (t * t * t + 1) + b
	else
		t, c = ((t * 2) - d) / d, c * 0.5
		return c * t * t * t + b + c
	end
end

function Easing.inQuart(t, b, c, d)
	t = t / d
	return c * t * t * t * t + b
end

function Easing.outQuart(t, b, c, d)
	t = t / d - 1
	return -c * (t * t * t * t - 1) + b
end

function Easing.inOutQuart(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c * 0.5 * t * t * t * t + b
	else
		t = t - 2
		return -c * 0.5 * (t * t * t * t - 2) + b
	end
end

function Easing.outInQuart(t, b, c, d)
	if t < d * 0.5 then
		t, c = t * 2 / d - 1, c * 0.5
		return -c * (t * t * t * t - 1) + b
	else
		t, c = ((t * 2) - d) / d, c * 0.5
		return c * t * t * t * t + b + c
	end
end

function Easing.inQuint(t, b, c, d)
	t = t / d
	return c * t * t * t * t * t + b
end

function Easing.outQuint(t, b, c, d)
	t = t / d - 1
	return c * (t * t * t * t * t + 1) + b
end

function Easing.inOutQuint(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c * 0.5 * t * t * t * t * t + b
	else
		t = t - 2
		return c * 0.5 * (t * t * t * t * t + 2) + b
	end
end

function Easing.outInQuint(t, b, c, d)
	if t < d * 0.5 then
		t = t * 2 / d - 1
		return c * 0.5 * (t * t * t * t * t + 1) + b
	else
		t, c = ((t * 2) - d) / d, c * 0.5
		return c * t * t * t * t * t + b + c
	end
end

function Easing.inSine(t, b, c, d)
	return -c * cos(t / d * _halfpi) + c + b
end

function Easing.outSine(t, b, c, d)
	return c * sin(t / d * _halfpi) + b
end

function Easing.inOutSine(t, b, c, d)
	return -c * 0.5 * (cos(pi * t / d) - 1) + b
end

function Easing.outInSine(t, b, c, d)
	c = c * 0.5
	return t < d * 0.5 and c * sin(t * 2 / d * _halfpi) + b or -c * cos(((t * 2) - d) / d * _halfpi) + 2 * c + b
end

function Easing.inExpo(t, b, c, d)
	return t == 0 and b or c * 2 ^ (10 * (t / d - 1)) + b - c * 0.001
end

function Easing.outExpo(t, b, c, d)
	return t == d and b + c or c * 1.001 * (1 - 2 ^ (-10 * t / d)) + b
end

function Easing.inOutExpo(t, b, c, d)
	t = t / d * 2
	return t == 0 and b or t == 2 and b + c or t < 1 and c * 0.5 * 2 ^ (10 * (t - 1)) + b - c * 0.0005 or c * 0.5 * 1.0005 * (2 - 2 ^ (-10 * (t - 1))) + b
end

function Easing.outInExpo(t, b, c, d)
	c = c * 0.5
	return t < d * 0.5 and (t * 2 == d and b + c or c * 1.001 * (1 - 2 ^ (-20 * t / d)) + b) or t * 2 - d == 0 and b + c or c * 2 ^ (10 * ((t * 2 - d) / d - 1)) + b + c - c * 0.001
end

function Easing.inCirc(t, b, c, d)
	t = t / d
	return -c * ((1 - t * t) ^ 0.5 - 1) + b
end

function Easing.outCirc(t, b, c, d)
	t = t / d - 1
	return c * (1 - t * t) ^ 0.5 + b
end

function Easing.inOutCirc(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return -c * 0.5 * ((1 - t * t) ^ 0.5 - 1) + b
	else
		t = t - 2
		return c * 0.5 * ((1 - t * t) ^ 0.5 + 1) + b
	end
end

function Easing.outInCirc(t, b, c, d)
	c = c * 0.5
	if t < d * 0.5 then
		t = t * 2 / d - 1
		return c * (1 - t * t) ^ 0.5 + b
	else
		t = (t * 2 - d) / d
		return -c * ((1 - t * t) ^ 0.5 - 1) + b + c
	end
end

function Easing.inElastic(t, b, c, d, a, p)
	t = t / d - 1
	p = p or d * 0.3
	return t == -1 and b or t == 0 and b + c or (not a or a < abs(c)) and -(c * 2 ^ (10 * t) * sin((t * d - p * .25) * _2pi / p)) + b or -(a * 2 ^ (10 * t) * sin((t * d - p / _2pi * asin(c/a)) * _2pi / p)) + b
end

function Easing.outElastic(t, b, c, d, a, p)
	t = t / d
	p = p or d * 0.3
	return t == 0 and b or t == 1 and b + c or (not a or a < abs(c)) and c * 2 ^ (-10 * t) * sin((t * d - p * .25) * _2pi / p) + c + b or a * 2 ^ (-10 * t) * sin((t * d - p / _2pi * asin(c / a)) * _2pi / p) + c + b
end

function Easing.inOutElastic(t, b, c, d, a, p)
	if t == 0 then
		return b
	end

	t = t / d * 2 - 1

	if t == 1 then
		return b + c
	end

	p = p or d * .45
	a = a or 0

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
end

function Easing.outInElastic(t, b, c, d, a, p)
	if t < d * 0.5 then
		return Easing.outElastic(t * 2, b, c * 0.5, d, a, p)
	else
		return Easing.inElastic(t * 2 - d, b + c * 0.5, c * 0.5, d, a, p)
	end
end

function Easing.inBack(t, b, c, d, s)
	s = s or 1.70158
	t = t / d
	return c * t * t * ((s + 1) * t - s) + b
end

function Easing.outBack(t, b, c, d, s)
	s = s or 1.70158
	t = t / d - 1
	return c * (t * t * ((s + 1) * t + s) + 1) + b
end

function Easing.inOutBack(t, b, c, d, s)
	s = (s or 1.70158) * 1.525
	t = t / d * 2
	if t < 1 then
		return c * 0.5 * (t * t * ((s + 1) * t - s)) + b
	else
		t = t - 2
		return c * 0.5 * (t * t * ((s + 1) * t + s) + 2) + b
	end
end

function Easing.outInBack(t, b, c, d, s)
	c = c * 0.5
	s = s or 1.70158
	if t < d * 0.5 then
		t = (t * 2) / d - 1
		return c * (t * t * ((s + 1) * t + s) + 1) + b
	else
		t = ((t * 2) - d) / d
		return c * t * t * ((s + 1) * t - s) + b + c
	end
end

function Easing.outBounce(t, b, c, d)
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

function Easing.inBounce(t, b, c, d)
	return c - Easing.outBounce(d - t, 0, c, d) + b
end

function Easing.inOutBounce(t, b, c, d)
	if t < d * 0.5 then
		return Easing.inBounce(t * 2, 0, c, d) * 0.5 + b
	else
		return Easing.outBounce(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b
	end
end

function Easing.outInBounce(t, b, c, d)
	if t < d * 0.5 then
		return Easing.outBounce(t * 2, b, c * 0.5, d)
	else
		return Easing.inBounce(t * 2 - d, b + c * 0.5, c * 0.5, d)
	end
end

-- Smooth Interpolation Curve Generator
-- @author Validark
-- @testsite http://cubic-bezier.com/
-- @testsite http://greweb.me/bezier-easing-editor/example/

-- Bezier.new(x1, y1, x2, y2)

-- @param numbers (x1, y1, x2, y2) The control points of your curve

-- @returns function(t [b, c, d])
--	@param number t the time elapsed [0, d]
--	@param number b beginning value being interpolated (default = 0)
--	@param number c change in value being interpolated (equivalent to: ending - beginning) (default = 1)
--	@param number d duration interpolation is occurring over (default = 1)

-- These values are established by empiricism with tests (tradeoff: performance VS precision)
local NEWTON_ITERATIONS = 4
local NEWTON_MIN_SLOPE = 0.001
local SUBDIVISION_PRECISION = 0.0000001
local SUBDIVISION_MAX_ITERATIONS = 10
local K_SPLINE_TABLE_SIZE = 11

local K_SAMPLE_STEP_SIZE = 1 / (K_SPLINE_TABLE_SIZE - 1)

local Bezier = {}

function Bezier.new(x1, y1, x2, y2)
	if not (x1 and y1 and x2 and y2) then error("Need 4 numbers to construct a Bezier curve") end
	if not (0 <= x1 and x1 <= 1 and 0 <= x2 and x2 <= 1) then error("The x values must be within range [0, 1]") end

	if x1 == y1 and x2 == y2 then
		return function(t, b, c, d)
			return (c or 1)*t / (d or 1) + (b or 0)
		end
	end

	-- Precompute redundant values
	local e, f = 3*x1, 3*x2
	local g, h, i = 1 - f + e, f - 2*e, 3*(1 - f + e)
	local j, k = 2*h, 3*y1
	local l, m = 1 - 3*y2 + k, 3*y2 - 2*k

	-- Precompute samples table
	local SampleValues = {}
	for a = 0, K_SPLINE_TABLE_SIZE - 1 do
		local z = a*K_SAMPLE_STEP_SIZE
		SampleValues[a] = ((g*z + h)*z + e)*z -- CalcBezier
	end

	return function(t, b, c, d)
		t = (c or 1)*t / (d or 1) + (b or 0)

		if t == 0 or t == 1 then -- Make sure the endpoints are correct
			return t
		end

		local CurrentSample = K_SPLINE_TABLE_SIZE - 2

		for a = 1, CurrentSample do
			if SampleValues[a] > t then
				CurrentSample = a - 1
				break
			end
		end

		-- Interpolate to provide an initial guess for t
		local IntervalStart = CurrentSample*K_SAMPLE_STEP_SIZE
		local GuessForT = IntervalStart + K_SAMPLE_STEP_SIZE*(t - SampleValues[CurrentSample]) / (SampleValues[CurrentSample + 1] - SampleValues[CurrentSample])
		local InitialSlope = (i*GuessForT + j)*GuessForT + e

		if InitialSlope >= NEWTON_MIN_SLOPE then
			for NewtonRaphsonIterate = 1, NEWTON_ITERATIONS do
				local CurrentSlope = (i*GuessForT + j)*GuessForT + e
				if CurrentSlope == 0 then break end
				GuessForT = GuessForT - (((g*GuessForT + h)*GuessForT + e)*GuessForT - t) / CurrentSlope
			end
		elseif InitialSlope ~= 0 then
			local IntervalStep = IntervalStart + K_SAMPLE_STEP_SIZE

			for BinarySubdivide = 1, SUBDIVISION_MAX_ITERATIONS do
				GuessForT = IntervalStart + 0.5*(IntervalStep - IntervalStart)
				local BezierCalculation = ((g*GuessForT + h)*GuessForT + e)*GuessForT - t

				if BezierCalculation > 0 then
					IntervalStep = GuessForT
				else
					IntervalStart = GuessForT
					BezierCalculation = -BezierCalculation
				end

				if BezierCalculation <= SUBDIVISION_PRECISION then break end
			end
		end

		return ((l*GuessForT + m)*GuessForT + k)*GuessForT
	end
end

Sharp = Bezier.new(0.4, 0, 0.6, 1)
Standard = Bezier.new(0.4, 0, 0.2, 1)
Acceleration = Bezier.new(0.4, 0, 1, 1)
Deceleration = Bezier.new(0, 0, 0.2, 1)

return Easing
