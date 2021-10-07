extends Node

class_name EnemyAI

var enemy_name: String
var id: int
var base_color: Color
var regions: Array

func _init(data: Dictionary):
	enemy_name = data['name']
	id = data['id']
	var c: Array = data['color']
	var base: float = 1.0 / 256.0
	base_color = Color(base * float(c[0]), base * float(c[1]), base * float(c[2]), 1.0)
	regions = data['regions']

func add_region(new_region: MapRegion) -> void:
	regions.append(new_region)
