tool
extends HBoxContainer

export(String) var region_name setget set_name

func _ready():
	pass

func set_name(new_name:String) -> void:
	$Label.text = new_name
