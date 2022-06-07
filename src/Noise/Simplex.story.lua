return function(coreGui)
	print("Running")
	local Noise = require(script.Parent)
	local Vector = require(script.Parent.Parent:WaitForChild("Algebra"):WaitForChild("Vector"))
	local Matrix = require(script.Parent.Parent:WaitForChild("Algebra"):WaitForChild("Matrix"))

	local seed = 1277

	local Map = Noise.Simplex.new()
	Map:SetSeed(seed)
	Map:SetFrequency(4)
	Map:SetAmplitude(0.5)
	Map:SetLacunarity(2)
	Map:SetPersistence(0.5)

	local Details = Noise.Simplex.new()
	Details:SetSeed(seed*2)
	Map:InsertOctave(Details)

	local Details2 = Details:Clone()
	Details2:SetSeed(seed*3)
	Map:InsertOctave(Details2)

	local resolution = 16*4
	local ratio = 1+math.floor(300/resolution)
	local matrix = Map:ToMatrix(resolution)
	print("Drawing")
	Map:Debug(coreGui, ratio, matrix)
	print("Done")
	return function() end
end