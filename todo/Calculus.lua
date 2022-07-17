
local types = require(script.Parent.Types)
export type Point = types.Point
export type Vertex = types.Vertex
export type Normal = types.Normal
export type Axis = types.Axis
export type Direction = types.Direction
export type Line = types.Line
export type Radian = types.Radian
export type Function = (x: number) -> Function | number

local Calculus = {}

function Calculus.getDerivative(f: Function, deltaX: number): Function
	return function (x: number): number
		local zero = f(x)
		local post = f(x+deltaX)
		return (post-zero)/deltaX
	end
end

function Calculus.getIntegral(f: Function, deltaX: number): Function --returns a function that will show graph "area" at X

	return function(): number
		
	end
end


return Calculus