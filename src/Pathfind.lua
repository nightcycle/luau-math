local Pathfinder = {}
Pathfinder.__index = {}

export type Pathfinder<T> = (start:T, finish:T) -> ({[number]: T})

return function<T>(network: {[T]: {[number]: T}}): Pathfinder<T>
	local weightedNetwork: {[T]: {[T]: number}} = {}
	for s, connections in pairs(network) do
		weightedNetwork[s] = {}
		for i, d in ipairs(connections) do
			weightedNetwork[s][d] = (d-s).Magnitude
		end
	end
	return function(start: T, finish: T)

	end
end