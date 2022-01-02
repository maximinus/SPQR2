extends Control

func _ready():
	pass

func setup():
	pass

func fade_in():
	show()
	$Anim.play('FadeIn')

func fade_out():
	$Anim.play('FadeOut')

func _on_Anim_animation_finished(anim_name):
	if anim_name == 'FadeOut':
		queue_free()

func _on_NodeDetailsTooltip_resized():
	var new_size = rect_size.y + 36.0
	$Panel.rect_size.x = 230.0
	$Panel.rect_size.y = new_size
	# change size and height of atlas texture
	$Background.rect_size.y = new_size
	$Background.texture.region.end.y = new_size
