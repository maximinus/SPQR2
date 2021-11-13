extends Node

class_name Army

var id: int
var strength: int
var morale: int
var equipment: int
var training: int
var node_id: int
var owner_id: int

func _init(data: Dictionary, c_owner, new_id):
	id = new_id
	strength = data['unit_strength']
	morale = 10
	equipment = 10
	training = 10
	node_id = data['id']
	owner_id = c_owner
