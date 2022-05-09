return function()
	it("should boot", function()
		local success, msg = pcall(function()
			require(script.Parent)
		end)
		expect(success).to.be.equal(true)
	end)

end
