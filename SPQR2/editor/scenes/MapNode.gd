tool
extends Node2D

export(String) var city_name = 'None'
export(int) var population = 0
export(bool) var has_city setget set_city_state
export(int) var wealth = 0
export(int) var romanisation = 0
export(int) var happiness = 0
export(int) var christian = 0
# unit details
export(String, 'None', 'Roman', 'Celt') var unit_type setget set_unit_type
export(int) var unit_strength = 0

var id:int = 0
var fully_loaded = false

func _ready() -> void:
	fully_loaded = true
	set_unit_type(unit_type)

func set_city_state(city: bool) -> void:
	if city == true:
		$Nodeimage.hide()
		$CityImage.show()
	else:
		$Nodeimage.show()
		$CityImage.hide()

func set_unit_type(new_unit: String) -> void:
	unit_type = new_unit
	if fully_loaded == false:
		return
	if unit_type == 'None':
		$RomanImage.hide()
		$EnemyImage.hide()
		return
	if unit_type == 'Roman':
		$RomanImage.show()
		$EnemyImage.hide()
	else:
		$RomanImage.hide()
		$EnemyImage.show()

func get_data():
	var id_owner = -1
	if unit_type == 'Roman':
		id_owner = 0
	elif unit_type == 'Celt':
		id_owner = 1
	return {
		'city_name': city_name,
		'population': population,
		'romanisation': romanisation,
		'wealth': wealth,
		'happiness': happiness,
		'christianity': christian,
		'unit': id_owner,
		'unit_strength': unit_strength
	}

func get_unit_data():
	var roman = true if unit_type == 'Roman' else false
	if unit_type == 'None':
		return {'strength':0, 'Roman':roman}

func has_unit() -> bool:
	if unit_type == 'None':
		return false
	return true
