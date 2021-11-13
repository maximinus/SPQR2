tool
extends HBoxContainer

export(String) var region_name setget set_name
export(String, 'Roman', 'Celt') var owned_by setget set_region_owner
var current_color: Color = cn.ROME_DEFAULT_COLOR
var needs_update = false

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
