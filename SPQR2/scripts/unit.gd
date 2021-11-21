extends Node

class_name Unit

var id: int
var strength: int
var morale: int
var equipment: int
var training: int
var location
var owner_id: int

func _init(data: Dictionary, c_owner, new_id, location_node):
	# the unit should KNOW it's node, not just have the id
	id = new_id
	# strength is number of troops
	# morale, equipment and training all vary from 0 to 9
	strength = data['unit_strength']
	morale = data['unit_morale']
	equipment = data['unit_equipment']
	training = data['unit_training']
	location = location_node
	owner_id = c_owner

func get_map_position() -> Vector2:
	# just need the position of the node	
	return data.get_node_position(location.id)

func get_region_id() -> int:
	return location.region_id

func is_roman() -> bool:
	return owner_id == 0
