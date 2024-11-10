extends Node2D


func _ready() -> void:
	var base_image = Image.create(2, 2, false, Image.FORMAT_RGB8)
	base_image.set_pixel(0, 0, Color(1.0, 0.0, 0.0))
	base_image.set_pixel(1, 0, Color(0.0, 1.0, 0.0))
	base_image.set_pixel(0, 1, Color(1.0, 1.0, 0.0))
	base_image.set_pixel(1, 1, Color(0.0, 1.0, 1.0))
	%Sprite2D.material.set_shader_parameter('image', ImageTexture.create_from_image(base_image))
