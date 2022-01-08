extends Control

func _ready():
	pass

func set_title(text) -> void:
	$MarginContainer/Label.text = text
	#$MarginContainer2/ColorOverlay.material.set_shader_param('color', color)
