extends Control

var node_data = null

func _ready():
	pass

func set_data(node_info) -> void:
	node_data = node_info
	$Mrg/HBox/Population.set_icon_text(str(node_data.population))
	$Mrg/HBox/Roman.set_icon_text(str(node_data.romanisation))
	$Mrg/HBox/Money.set_icon_text(str(node_data.wealth))
	$Mrg/HBox/Happy.set_icon_text(str(node_data.happiness))
	$Mrg/HBox/Christian.set_icon_text(str(node_data.christianty))
