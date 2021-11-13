extends Node

class_name EnemyAI

var enemy_name: String
var id: int
var base_color: Color
var gold: int
var silver: int

func _init(data: Dictionary):
	enemy_name = data['name']
	id = data['id']
	if id == 0:
		base_color = cn.ROME_DEFAULT_COLOR
	else:
		base_color = cn.CELT_COLOR
	gold = data['gold']
	silver = data['silver']

static func sort(a, b) -> bool:
	if a.id < b.id:
		return true
	return false
