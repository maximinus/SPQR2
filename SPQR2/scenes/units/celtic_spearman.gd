extends Spatial

signal clicked

func _ready():
	pass

func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event.is_pressed() and event.button_index == BUTTON_LEFT:
		emit_signal('clicked')

func set_scale(new_scale):
	$celtic_spearman.scale = new_scale
	$Area.scale = new_scale
