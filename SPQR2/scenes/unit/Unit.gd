extends Node2D

func _ready():
	pass

func startHighlight():
	pass

func stopHighlight():
	pass

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	# flash when clicked
	if (event is InputEventMouseButton and event.pressed):
		$Anim.play('Flash')
