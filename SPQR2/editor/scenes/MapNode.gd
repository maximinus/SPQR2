tool
extends Node2D

export(String) var city_name = 'None'
export(int) var population = 0 setget set_population
export(int) var culture = 0
export(int) var wealth = 0
export(int) var manpower = 0
export(int) var romanisation = 0
# unit details
export(String, 'None', 'Roman', 'Celt') var unit_type setget set_unit_type
export(int) var unit_strength = 0
export(int, 9) var morale = 0
export(int, 9) var training = 0
export(int, 9) var equipment = 0

var id:int = 0
var fully_loaded = false

func _ready():
	fully_loaded = true
	set_unit_type(unit_type)

func set_population(new_pop: int) -> void:
	population = new_pop
	if new_pop > 2:
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
		'culture': culture,
		'wealth': wealth,
		'manpower': manpower,
		'romanisation': romanisation,
		'unit': id_owner,
		'unit_strength': unit_strength,
		'unit_morale': morale,
		'unit_equipment': equipment,
		'unit_training': training
	}

func get_unit_data():
	var roman = true if unit_type == 'Roman' else false
	if unit_type == 'None':
		return {'strength':0, 'Roman':roman}

func has_unit() -> bool:
	if unit_type == 'None':
		return false
	return true
