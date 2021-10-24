extends Spatial

signal clicked

func _ready():
	pass

func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	# the model got an input event
	# we want to know if it was a click
	if event.is_pressed() and event.button_index == BUTTON_LEFT:
		emit_signal('clicked')

func set_scale(new_scale):
	$roman_spearman.scale = new_scale
	$Area.scale = new_scale
