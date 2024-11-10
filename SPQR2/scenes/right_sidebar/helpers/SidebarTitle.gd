extends Control

func _ready():
	pass

func set_title(text) -> void:
	$MarginContainer/Label.text = text
