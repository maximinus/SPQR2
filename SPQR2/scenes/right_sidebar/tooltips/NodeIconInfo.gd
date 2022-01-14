extends Control

func _ready():
	pass

func setup(offset, text) -> void:
	$Mrg/HBox/Icon.texture.region.position.x = offset
	$Mrg/HBox/Label.text = text
