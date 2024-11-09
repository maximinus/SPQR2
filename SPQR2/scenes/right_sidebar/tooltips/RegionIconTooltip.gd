extends Control

var min_size_x: int = 42

func _ready():
	set_as_top_level(true)

func setup(tex: AtlasTexture, title: String, message: String):
	$Panel/Mrg/VBox/HBox/Icon.texture = tex
	$Panel/Mrg/VBox/Title.text = title
	$Panel/Mrg/VBox/HBox/Message.visible = false
	$Panel/Mrg/VBox/HBox/Message.text = message
	$Panel/Mrg/VBox/HBox/Message.visible = true

func _on_Message_resized():
	var new_size = $Panel/Mrg/VBox/HBox/Message.size.y + min_size_x
	size.y = new_size
	$Panel.size.y = new_size
	# change size and height of atlas texture
	$Background.size.y = new_size
	$Background.texture.region.end.y = new_size

func fade_in():
	show()
	$Anim.play('FadeIn')

func fade_out():
	$Anim.play('FadeOut')

func _on_Anim_animation_finished(anim_name):
	if anim_name == 'FadeOut':
		queue_free()
