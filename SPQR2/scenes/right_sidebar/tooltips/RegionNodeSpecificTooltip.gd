extends Control

const BOTTOM_BORDER_MARGIN: int = 8

var info_scene = preload('res://scenes/right_sidebar/tooltips/NodeIconInfo.tscn')

func _ready():
	set_as_toplevel(true)

func setup(title: String, icon_list: Array) -> void:
	$Panel/Mrg/VBox/MrgLbl/Label.text = title
	# icon list is offset value for atlas texture and the text to go with it
	for data in icon_list:
		var new_info_bar = info_scene.instance()
		new_info_bar.setup(data[0], data[1])
		$Panel/Mrg/VBox.add_child(new_info_bar)

func fade_in() -> void:
	show()
	$Anim.play('FadeIn')

func fade_out() -> void:
	$Anim.play('FadeOut')

func _on_Anim_animation_finished(anim_name):
	if anim_name == 'FadeOut':
		queue_free()

func _on_VBox_resized():
	var new_size = $Panel/Mrg/VBox.rect_size.y + BOTTOM_BORDER_MARGIN
	rect_size.y = new_size
	# change size and height of atlas texture
	$Background.rect_size.y = new_size
	$Background.texture.region.end.y = new_size
