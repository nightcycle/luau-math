local Algebra = require(script.Parent.Parent:WaitForChild("Algebra"))

return function()
	local alpha = 0.5
	describe("Lerp", function()
		it("should lerp Vector2s", function()
			local a = Vector2.new(0,0)
			local b = Vector2.new(1,1)
			local v = Algebra.lerp(a,b,alpha)
			expect(v).to.be.equal(Vector2.new(0.5,0.5))
		end)
		it("should lerp strings", function()
			local a = "Apple"
			local b = "Banana"
			local v = Algebra.lerp(a,b,alpha)
			expect(v).to.be.equal("Banple")
		end)
	end)
end

--[[
local alpha = 0.5
local Algebra = require(game.ReplicatedStorage.Packages.src.Algebra)
local a = ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.new(1,0,0)),
	ColorSequenceKeypoint.new(1,Color3.new(0,0,1)),
})
local b = ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),
	ColorSequenceKeypoint.new(0,Color3.new(0,0,0.5)),
	ColorSequenceKeypoint.new(1,Color3.new(0,1,0)),
})
local count = 250
for i=1, count do
	task.wait()
	workspace.ParticleEmitter.Color = Algebra.lerp(a,b,i/count)
end
]]--