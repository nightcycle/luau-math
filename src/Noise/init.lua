--!strict
local Vector = require(script.Parent:WaitForChild("Algebra"):WaitForChild("Vector"))
export type Vector = Vector.Vector

local Matrix = require(script.Parent:WaitForChild("Algebra"):WaitForChild("Matrix"))
type Matrix = Matrix.Matrix

local Solver = require(script:WaitForChild("Solver"))
export type NoiseSolver = Solver.NoiseSolver
return {
	Random = require(script:WaitForChild("Solver")),
	Simplex = require(script:WaitForChild("Simplex")),
	Cellular = require(script:WaitForChild("Cellular")),
	Voronoi = require(script:WaitForChild("Voronoi")),
}
