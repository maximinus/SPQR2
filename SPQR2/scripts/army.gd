extends Node

class_name Army

var id: int
var name_text: String
var strength: int
var morale: int
var equipment: int
var training: int
var location: int
var location_index: int

func _init(data: Dictionary):
	id = data['id']
	name_text = data['name']
	strength = data['strength']
	morale = data['morale']
	equipment = data['equipment']
	training = data['training']
	location = data['location']
	location_index = data['index']

func get_map_position():
	return data.regions[location].army_pos[location_index]
