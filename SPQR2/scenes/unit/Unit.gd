extends Spatial

const MODEL_SCALE = Vector3(0.07, 0.07, 0.07)

# preload the models
var models = [preload('res://scenes/units/roman_spear.tscn'),
			  preload('res://scenes/units/celtic_spearman.tscn')]

func _ready():
	pass

func set_unit_type(owner):
	if owner >= 0 and owner < len(models):
		return
	$roman_spear.queue_free()
	var model_instance = models[0].instance()
	model_instance.scale(MODEL_SCALE)
	$Unit.add_child(model_instance)

func highlight_on():
	$Circle.show()
	$Highlight.play('HighlightRotate')

func highlight_off():
	$Circle.hide()
	$Highlight.stop()
