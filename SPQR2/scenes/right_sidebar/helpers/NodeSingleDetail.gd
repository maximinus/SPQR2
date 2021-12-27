tool
extends HBoxContainer

export(Texture) var icon_texture setget set_icon_texture
export(String) var icon_text setget set_icon_text

func _ready():
	pass

func set_icon_texture(new_texture: Texture) -> void:
	$Mrg1/Icon.texture = new_texture
	icon_texture = new_texture

func set_icon_text(new_text: String) -> void:
	$Mrg2/Label.text = new_text
	icon_text = new_text
