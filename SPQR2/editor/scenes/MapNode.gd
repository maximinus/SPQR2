@tool
extends Node2D

@export var city_name: String = 'None'
@export var population: int = 0
@export var has_city: bool: set = set_city_state
@export var wealth: int = 0
@export var romanisation: int = 0
@export var happiness: int = 0
@export var christian: int = 0
# unit details
@export var unit_type : set = set_unit_type

# and the units
@export var Unit1: Resource
@export var Unit2: Resource
@export var Unit3: Resource
@export var Unit4: Resource

var id:int = 0
var fully_loaded = false

func _ready() -> void:
	fully_loaded = true
	set_unit_type(unit_type)
	# it's not clever but it works for small fixed-size arrays
	# as of Godot 3.5, you cannot export a custom class
	if not Unit1:
		Unit1 = SPQR_EditorUnit.new().duplicate(false)
		Unit1.setup_local_to_scene(true)
	if not Unit2:
		Unit2 = SPQR_EditorUnit.new().duplicate(false)
		#Unit2.setup_local_to_scene(true)
	if not Unit3:
		Unit3 = SPQR_EditorUnit.new().duplicate(false)
		#Unit3.setup_local_to_scene(true)
	if not Unit4:
		Unit4 = SPQR_EditorUnit.new().duplicate(false)
		#Unit4.setup_local_to_scene(true)

func set_city_state(city: bool) -> void:
	has_city = city
	if has_city == true:
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

func get_data() -> Dictionary:
	return {
		'city_name': city_name,
		'has_city': has_city,
		'population': population,
		'romanisation': romanisation,
		'wealth': wealth,
		'happiness': happiness,
		'christianity': christian,
	}

func get_unit_data():
	var id_owner = -1
	if unit_type == 'Roman':
		id_owner = 0
	elif unit_type == 'Celt':
		id_owner = 1
	var roman = true if unit_type == 'Roman' else false
	# check all units
	var units = []
	for i in [Unit1, Unit2, Unit3, Unit4]:
		var unit_data = get_single_unit(i)
		if unit_data != null:
			units.append(unit_data)
	if len(units) == 0:
		return null
	return {'units':units, 'owner':id_owner}

func get_single_unit(unit):
	if not unit:
		# no resource
		return null
	if unit.foot + unit.mounted <= 0:
		# can't have a unit without troops!
		return null
	return {'foot': unit.foot,
			'mounted': unit.mounted,
			'quality': unit.quality,
			'morale': unit.morale}

func has_unit() -> bool:
	if unit_type == 'None':
		return false
	return true
