extends Control

var min_size_x: int = 42

func _ready():
	pass

func setup(tex: AtlasTexture, title: String, message: String):
	$Panel/Mrg/VBox/HBox/Icon.texture = tex
	$Panel/Mrg/VBox/Title.text = title
	$Panel/Mrg/VBox/HBox/Message.visible = false
	$Panel/Mrg/VBox/HBox/Message.text = message
	$Panel/Mrg/VBox/HBox/Message.visible = true

func _on_Message_resized():
	var new_size = $Panel/Mrg/VBox/HBox/Message.rect_size.y + min_size_x
	rect_size.y = new_size
	$Panel.rect_size.y = new_size
	# change size and height of atlas texture
	$Background.rect_size.y = new_size
	$Background.texture.region.end.y = new_size
