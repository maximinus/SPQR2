extends Node

class_name EnemyAI

var enemy_name: String
var id: int

func _init(data: Dictionary):
	self.enemy_name = data['name']
	self.id = data['id']
