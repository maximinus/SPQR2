tool
extends Line2D

export(int) var id setget update_lbl

func _ready():
	pass # Replace with function body.

func update_lbl(value) -> void:
	$Label.text = str(value)
	id = value
