@tool
extends HBoxContainer

@export var icon_texture: Texture2D: set = set_icon_texture
@export var icon_text: String: set = set_icon_text

func _ready():
	pass

func set_icon_texture(new_texture: Texture2D) -> void:
	$Mrg1/Icon.texture = new_texture
	icon_texture = new_texture

func set_icon_text(new_text: String) -> void:
	$Mrg2/Label.text = new_text
	icon_text = new_text
