local cframe = {}

function getPlaneCFrame(planeNormal)
	return CFrame.fromMatrix(Vector3.new(0,0,0), Vector3.new(0,0,1):Cross(planeNormal), planeNormal)
end

function cframe.getTiltBetween(planeNormal:Vector3, a:CFrame, b:CFrame)
	local planeCF = getPlaneCFrame(planeNormal)

	local pA = a:ToObjectSpace(planeCF)
	local pB = b:ToObjectSpace(planeCF)
	local difference = pA:Inverse() * pB
	local tilt,_,_ = difference:ToEulerAnglesXYZ()

	local fA = (pA*CFrame.Angles(tilt,0,0)):ToWorldSpace(planeCF)
	local fDifference = a:Inverse() * fA
	local x,y,z = fDifference:ToEulerAnglesXYZ()
	return Vector3.new(x,y,z), tilt
end

function cframe.getPanBetween(planeNormal:Vector3, a:CFrame, b:CFrame)
	local planeCF = getPlaneCFrame(planeNormal)

	local pA = a:ToObjectSpace(planeCF)
	local pB = b:ToObjectSpace(planeCF)
	local difference = pA:Inverse() * pB
	local _,pan,_ = difference:ToEulerAnglesYXZ()

	local fA = (pA*CFrame.Angles(0,pan,0)):ToWorldSpace(planeCF)
	local fDifference = a:Inverse() * fA
	local x,y,z = fDifference:ToEulerAnglesYXZ()
	return Vector3.new(x,y,z), pan
end

-- function cframe.getPanBetween(planeNormal:Vector3, a, b)
	-- local planeCF = getPlaneCFrame(planeNormal)
	-- local pA = a:ToObjectSpace(planeCF)
	-- local pB = b:ToObjectSpace(planeCF)
	-- local difference = pA:Inverse() * pB:Inverse()
	-- local axis, angle = difference:ToAxisAngle()
	-- local fA = (pA * CFrame.Angles(0,angle,0)):ToWorldSpace()
	-- local fDifference = a:Inverse() * fA
	-- local x,y,z = fDifference:ToEulerAnglesYXZ()
	-- return Vector3.new(x,y,z), angle
	-- local pAX, panA = pA:ToEulerAnglesYXZ()
	-- local pBX, panB = pA:ToEulerAnglesYXZ()
	-- print(pAX, pBX)
	-- local euler = require(script.Parent:WaitForChild("Euler"))
	-- local deltaPan = euler.eulerDistance(panB, panA)
	-- local rollCF = CFrame.fromAxisAngle(planeNormal, deltaPan)
	-- local rDifference = a:Inverse() * rollCF
	-- local x,y,z = rDifference:ToEulerAnglesXYZ()
	-- return Vector3.new(x,y,z), deltaPan
-- end

return cframe