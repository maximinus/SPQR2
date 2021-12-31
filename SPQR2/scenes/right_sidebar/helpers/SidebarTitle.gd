extends Control

func _ready():
	pass

func setTitle(text, color):
	$MarginContainer/Label.text = text
	$MarginContainer2/ColorOverlay.material.set_shader_param('color', color)
