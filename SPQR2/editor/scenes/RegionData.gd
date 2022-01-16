tool
extends HBoxContainer

export(String) var region_name setget set_name
export(String, 'Mountain', 'Hills', 'Plain', 'Desert', 'Forest') var terrain
export(String, 'Maritime', 'Mediterranean', 'Desert', 'Humid') var climate
export(int, 0, 10) var crops
export(String, 'Roman', 'Celt') var owned_by setget set_region_owner
var current_color: Color = cn.ROME_DEFAULT_COLOR
var needs_update = false

	# these have to match the offsets of the atlastextures
const TERRAIN_STRINGS = ['Mountain', 'Hills', 'Plain', 'Desert', 'Forest']
const CLIMATE_STRINGS = ['Maritime', 'Mediterranean', 'Desert', 'Humid']

func _ready():
	pass

func set_name(new_name:String) -> void:
	region_name = new_name
	$Label.text = new_name

func set_region_owner(new_owner:String) -> void:
	# if same, do nothing
	if new_owner != owned_by:
		owned_by = new_owner
		if owned_by == 'Roman':
			current_color = cn.ROME_DEFAULT_COLOR
		else:
			current_color = cn.CELT_COLOR
		needs_update = true

func get_owner_id() -> int:
	# 0 if owned by Rome
	if owned_by == 'Roman':
		return 0
	return 1

func get_terrain_int() -> int:
	var index = 0
	for i in TERRAIN_STRINGS:
		if terrain == i:
			return index
	return 0

func get_climate_int():
	var index = 0
	for i in CLIMATE_STRINGS:
		if climate == i:
			return index
	return 0
