local Math = {
	abs = math.abs,-- Returns the absolute value of x.
	acos = math.acos,-- Returns the arc cosine of x.
	asin = math.asin,-- Returns the arc sine of x.
	atan = math.atan,-- Returns the arc tangent of x (in radians).
	atan2 = math.atan2,-- Returns the arc tangent of y/x (in radians), but uses the signs of both parameters to find the quadrant of the result. It also handles correctly the case of x being zero.
	ceil = math.ceil,-- Returns the smallest integer larger than or equal to x.
	clamp = math.clamp,-- Returns a between min and max, inclusive.
	cos = math.cos,-- Returns the cosine of x (assumed to be in radians).
	cosh = math.cosh,-- Returns the hyperbolic cosine of x.
	deg = math.deg,-- Returns the angle x (given in radians) in degrees.
	exp = math.exp,-- Returns the value e^x.
	floor = math.floor,-- Returns the largest integer smaller than or equal to x.
	fmod = math.fmod,-- Returns the remainder of the division of x by y that rounds the quotient towards zero.
	frexp = math.frexp,-- Returns m and e such that x = m*2^e, e is an integer and the absolute value of m is in the range [0.5, 1) (or zero when x is zero).
	ldexp = math.ldexp,-- Returns x*2^e (e should be an integer).
	log = math.log,-- Returns the logarithm of x using the given base, or the mathematical constant e if no base is provided (natural logarithm).
	log10 = math.log10,-- Returns the base-10 logarithm of x.
	max = math.max,-- Returns the maximum value among the numbers passed to the function.
	min = math.min,-- Returns the minimum value among the numbers passed to the function.
	modf = math.modf,-- Returns two numbers, the integral part of x and the fractional part of x.
	noise = math.noise,-- Returns a perlin noise value. The returned value is most often between the range [-1, 1].
	pow = math.pow,-- Returns x^y. (You can also use the expression x^y to compute this value.)
	rad = math.rad,-- Returns the angle x (given in degrees) in radians.
	random = math.random,-- An interface to the simple pseudo-random generator function rand provided by ANSI C. (No guarantees can be given for its statistical properties.) When called without arguments, returns a uniform pseudo-random real in the range [0,1). When called with an integer m, math.random returns a uniform pseudo-random integer in the range [1, m]. When called with two integer numbers m and n, math.random returns a uniform pseudo-random integer in the range [m, n].
	randomseed = math.randomseed,-- Sets x as the seed for the pseudo-random generator: equal seeds produce equal sequences of numbers.
	round = math.round,-- Returns the integer with the smallest difference between it and the given number. For example, the value 5.8 returns 6.
	sign = math.sign,-- Returns -1 if x < 0, 0 if x == 0, or 1 if x > 0.
	sin = math.sin,-- Returns the sine of x (assumed to be in radians).
	sinh = math.sinh,-- Returns the hyperbolic sine of x.
	sqrt = math.sqrt,-- Returns the square root of x. (You can also use the expression x^0.5 to compute this value.)
	tan = math.tan, -- Returns the tangent of x (assumed to be in radians).
	tanh = math.tanh, -- Returns the hyperbolic tangent of x.
	huge = math.huge, -- The value HUGE_VAL, a value larger than or equal to any other numerical value.
	pi = math.pi,-- The value of pi.
}

for i, mod in ipairs(script:GetChildren()) do
	Math[mod.Name] = require(mod)
end

return Math