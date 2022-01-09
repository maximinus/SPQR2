extends Control

func _ready():
	pass

func set_node_data(node_data):
	# this is a data.NewNode
	$VBoxContainer/NodeHeader.set_data(node_data)
	$VBoxContainer/NodeFooter.set_data(node_data)
