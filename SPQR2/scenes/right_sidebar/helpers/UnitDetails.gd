tool
extends MarginContainer

export(int, 5) var total_units setget set_total_units

func _ready():
	pass

func set_total_units(new_total: int) -> void:
	total_units = new_total
	var index: int = 0
	for i in $HBox.get_children():
		if index < total_units:
			i.show()
		else:
			i.hide()
		index += 1
