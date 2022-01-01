extends Control

const VERTICAL_SIZE_EMPTY: int = 11

var info_scene = preload('res://scenes/right_sidebar/tooltips/NodeIconInfo.tscn')

func _ready():
	pass

func setup(title: String, icon_list: Array) -> void:
	$Panel/Mrg/VBox/Label.text = title
	# we are expecting an array of [texture, string]
	print($Panel/Mrg/VBox.rect_size.y)
	for data in icon_list:
		var new_info_bar = info_scene.instance()
		new_info_bar.setup(data[0], data[1])
		$Panel/Mrg/VBox.add_child(new_info_bar)

func fade_in() -> void:
	show()
	$Anim.play('FadeIn')

func fade_out() -> void:
	$Anim.play('FadeOut')

func _on_VBox_resized():
	var new_size = $Panel/Mrg/VBox.rect_size.y + VERTICAL_SIZE_EMPTY
	print('New size:' + str(new_size))
	rect_size.y = new_size
	$Panel.rect_size.y = new_size
	$Panel/Mrg.rect_size.y = new_size
	# change size and height of atlas texture
	$Background.rect_size.y = new_size
	$Background.texture.region.end.y = new_size
