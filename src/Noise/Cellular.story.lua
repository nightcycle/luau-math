return function(coreGui)
	-- print("Running")
	local Noise = require(script.Parent)
	local Vector = require(script.Parent.Parent:WaitForChild("Algebra"):WaitForChild("Vector"))
	local Matrix = require(script.Parent.Parent:WaitForChild("Algebra"):WaitForChild("Matrix"))

	local Map = Noise.Cellular.new()
	Map:SetFrequency(1)
	Map:SetAmplitude(1)

	local resolution = 100
	local ratio = 1+math.floor(300/resolution)

	Map:GeneratePoints(30, Vector.new(0,0), Vector.new(1,1))
	local matrix = Map:ToMatrix(resolution)
	
	local highlightData = {}
	for x=1, resolution do
		highlightData[x] = {}
		for y=1, resolution do
			highlightData[x][y] = 0
		end
	end

	for i, vec in ipairs(Map.Points) do
		local rVec = (vec*resolution):Round()
		highlightData[rVec[1]][rVec[2]] = 1
	end
	local highlightVectors = {}
	for x=1, resolution do
		highlightVectors[x] = Vector.new(unpack(highlightData[x]))
	end
	local highlightMatrix = Matrix.new(unpack(highlightVectors))
	-- print("Drawing")
	Map:Debug(coreGui, ratio, highlightMatrix, matrix)
	-- print("Done")
	return function() end
end