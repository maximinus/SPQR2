extends Spatial

const MODEL_SCALE = Vector3(0.07, 0.07, 0.07)

# preload the models
var models = [preload('res://scenes/units/roman_spear.tscn'),
			  preload('res://scenes/units/celtic_spearman.tscn')]

func _ready():
	pass

func set_unit_type(owner) -> void:
	
	print(owner)
	
	if owner < 0 or owner >= len(models):
		helpers.log('Error: Owner id is out of range')
		return
	$roman_spear.queue_free()
	var model_instance = models[owner].instance()
	# set scale on first child of node
	model_instance.get_children()[0].scale = MODEL_SCALE
	add_child(model_instance)

func highlight_on() -> void:
	$Circle.show()
	$Highlight.play('HighlightRotate')

func highlight_off() -> void:
	$Circle.hide()
	$Highlight.stop()
