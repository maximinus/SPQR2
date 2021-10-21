extends Node

class_name EnemyAI

var enemy_name: String
var id: int
var base_color: Color
var regions: Array
var armies: Array
var gold: int
var silver: int

func _init(data: Dictionary):
	enemy_name = data['name']
	id = data['id']
	regions = data['regions']
	armies = data['armies']
	var c: Array = data['color']
	var base: float = 1.0 / 256.0
	base_color = Color(base * float(c[0]), base * float(c[1]), base * float(c[2]), 1.0)
	gold = data['gold']
	silver = data['silver']

func add_region(new_region: MapRegion) -> void:
	regions.append(new_region)
