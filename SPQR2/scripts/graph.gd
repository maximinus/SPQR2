extends Node

# the graph module looks after all things movement based
# it contains the astar setup for the game

const DEFAULT_WEIGHT = 1.0

var astar_data: AStar

func setup():
	# run this at game startup from data module, after data has been setup
	astar_data = AStar.new()
	for i in data.rnodes:
		var pos = Vector3(i.position.x, 0.0, i.position.y)
		astar_data.add_point(i.id, pos, DEFAULT_WEIGHT)
	
	# now we add the connections
	
