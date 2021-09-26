extends Node

class_name EnemyAI

var enemy_name: String
var id: int
var base_color: Color

func _init(data: Dictionary):
	self.enemy_name = data['name']
	self.id = data['id']
	var c: Array = data['color']
	var base: float = 1.0 / 256.0
	self.base_color = Color(base * float(c[0]), base * float(c[1]), base * float(c[2]), 1.0)
