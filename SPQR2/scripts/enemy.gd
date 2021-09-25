extends Node

class_name EnemyAI

var enemy_name: String
var id: int
var base_color: Color

func _init(data: Dictionary):
	self.enemy_name = data['name']
	self.id = data['id']
	var c: Array = data['color']
	self.base_color = Color(float(c[0]), float(c[1]), float(c[2]))
