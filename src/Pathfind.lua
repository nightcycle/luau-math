local Pathfinder = {}
Pathfinder.__index = {}

export type Pathfinder<T> = (start:T, finish:T) -> ({[number]: T})

--- @class PathFinder
--- A library of NoiseSolvers that combined can allow a developer to create many procedurally generated assets and mechanics.

return function<T>(network: {[T]: {[number]: T}}, scoreFunction: ((a: T, b: T) -> number)): Pathfinder<T>
	
	local weightedNetwork: {[T]: {[T]: number}} = {}
	for s, connections in pairs(network) do
		
		for i, d in ipairs(connections) do

			weightedNetwork[d] = weightedNetwork[d] or {}
			weightedNetwork[d][s] = scoreFunction(s, d)
		end
	end

	-- returns a dictionary of nodes with their path distances to goal
	local function getScoredDistances(goal: T): {[T]: number}
		local distances: {[T]: number} = {}
		distances[goal] = 0

		local queue = {}
		for n, _ in pairs(weightedNetwork) do
			if n ~= goal then
				distances[n] = math.huge
				table.insert(queue, n)
			end
		end

		local function scoreStep(node: T, prevDist: number)
			if node == goal then return end
			if distances[node] and distances[node] > prevDist then
				distances[node] = prevDist
				for n, dist in pairs(weightedNetwork[node]) do
					scoreStep(n, prevDist+dist)
				end
			end
		end

		for n: T, dist: number in pairs(weightedNetwork[goal]) do
			scoreStep(n, dist)
		end
		return distances
	end

	local pathCache: {[T]: {[T]: {[number]: T}}} = {}
	local distanceCache: {[T]: {[T]: number}} = {}
	return function(start: T, finish: T): {[number]: T}
		local path: {[number]: T} = {}

		--checks long term cache for existing solutions, otherwise solves from scratch and stores for later.
		pathCache[start] = pathCache[start] or {}
		if pathCache[start][finish] ~= nil then
			for i, node in ipairs(pathCache[start][finish]) do
				table.insert(path, node)
			end
		else
			--checks the distance cache to see if it needs to rescore the distances
			if distanceCache[finish] == nil then
				distanceCache[finish] = getScoredDistances(finish)
			end
			local distances: {[T]: number} = distanceCache[finish]

			--assembles the path by following the lowest distance scoring connections to the goal.
			local function assemblePath(node: T)
				table.insert(path, node)
				table.insert(pathCache[start][finish], node)
				if node == finish then return end
				local closestDist = math.huge
				local closestNode = nil
				for i, otherNode: T in ipairs(network[node] or {}) do
					local otherDist = distances[otherNode]
					if otherDist < closestDist then
						closestNode = otherNode
					end
				end
				if closestNode then
					assemblePath(closestNode)
				end
			end

			pathCache[start][finish] = {}
			assemblePath(start)

			--takes solved path, reverses it for caching
			local inversePath = {}
			for i, node in ipairs(path) do
				inversePath[#path-i+1] = node
			end
			pathCache[finish] = pathCache[finish] or {}
			pathCache[finish][start] = inversePath
		end
		return path
	end
end