extends Node3D

signal clicked

func _ready():
	pass

func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit()

func set_figure_scale(new_scale):
	%celtic_spearman2.scale = new_scale
	$Area3D.scale = new_scale
