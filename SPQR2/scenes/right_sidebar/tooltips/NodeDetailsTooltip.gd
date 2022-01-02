extends Control

func _ready():
	set_as_toplevel(true)

func setup() -> void:
	pass

func fade_in() -> void:
	show()
	$Anim.play('FadeIn')

func fade_out() -> void:
	$Anim.play('FadeOut')

func _on_Anim_animation_finished(anim_name) -> void:
	if anim_name == 'FadeOut':
		queue_free()

func _on_NodeDetailsTooltip_resized() -> void:
	var new_size = $Panel/Mrg/VBox.rect_size.y + 24.0
	$Panel.rect_size.x = 230.0
	$Panel.rect_size.y = new_size
	# change size and height of atlas texture
	$Background.rect_size.y = new_size
	$Background.texture.region.end.y = new_size
