extends Control

func _ready():
	pass

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

func _on_NodeUnitsTooltip_resized():
	rect_size.x = 230.0
	rect_size.y = 68.0
