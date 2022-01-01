extends Control

func _ready():
	pass

func setup(tex: Texture, text: String):
	$Mrg/HBox/Icon.texture = tex
	$Mrg/HBox/Label.text = text
