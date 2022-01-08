extends Control

func _ready():
	pass

func set_data(node_data):
	$VBoxContainer/NodeDetails.set_data(node_data)
	$VBoxContainer/UnitDetails.set_data(node_data)
