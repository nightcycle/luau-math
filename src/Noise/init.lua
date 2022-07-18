--!strict
local Vector = require(script.Parent.Algebra.Vector)
export type Vector = Vector.Vector

local Matrix = require(script.Parent.Algebra.Matrix)
type Matrix = Matrix.Matrix

local Solver = require(script.Solver)
export type NoiseSolver = Solver.NoiseSolver

--- @class Noise
--- A library of NoiseSolvers that combined can allow a developer to create many procedurally generated assets and mechanics.

local Noise = {}
Noise.__index = Noise

--- @prop Random NoiseSolver
--- @within Noise
--- A NoiseSolver that if shown in 2d would look like static.

Noise.Random = require(script:WaitForChild("Solver"))

--- @prop Simplex NoiseSolver
--- @within Noise
--- A NoiseSolver that if shown in 2d would look like terrain. It's optimized to run at 3 Dimensions or below, but it can handle more. 

Noise.Simplex = require(script:WaitForChild("Simplex"))

--- @prop Cellular NoiseSolver
--- @within Noise
--- A NoiseSolver that if shown in 2d would look like skin cells.

Noise.Cellular = require(script:WaitForChild("Cellular"))

--- @prop Voronoi NoiseSolver
--- @within Noise
--- A NoiseSolver that if shown in 2d would look like a stained glass window

Noise.Voronoi = require(script:WaitForChild("Voronoi"))

return Noise