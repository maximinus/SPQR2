extends Control

const UNIT_ROW_SIZE = 26
const LOWER_BORDER = 2
const TOOLTIP_MINIMUM_SIZE = 37

var row_resource = preload('res://scenes/right_sidebar/helpers/NodeUnitRow.tscn')

func _ready():
	set_as_toplevel(true)

func setup(units) -> void:
	for i in units:
		var row_instance = row_resource.instance()
		row_instance.setup(i)
		$Panel/MarginContainer/VBox.add_child(row_instance)
		resize_container(len(units))

func fade_in() -> void:
	show()
	$Anim.play('FadeIn')

func fade_out() -> void:
	$Anim.play('FadeOut')

func _on_Anim_animation_finished(anim_name) -> void:
	if anim_name == 'FadeOut':
		queue_free()

func resize_container(total_units):
	var ysize = TOOLTIP_MINIMUM_SIZE + LOWER_BORDER
	ysize += UNIT_ROW_SIZE * total_units
	rect_size.y = ysize
	$Background.texture.region.end.y = ysize
