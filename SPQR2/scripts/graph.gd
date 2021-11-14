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
	for i in data.roads:
		astar_data.connect_points(i.start_node, i.end_node)

func get_connected_nodes(node_id: int) -> PoolIntArray:
	# return a list of all nodes that are connected to this node
	return astar_data.get_point_connections(node_id)
