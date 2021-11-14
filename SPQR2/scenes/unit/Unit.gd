extends Spatial

const MODEL_SCALE = Vector3(0.07, 0.07, 0.07)
signal unit_clicked

# preload the models
var models = [preload('res://scenes/units/roman_spear.tscn'),
			  preload('res://scenes/units/celtic_spearman.tscn')]
var highlight = false
var id = -1

func _ready():
	pass

func set_unit_type(owner) -> void:
	if owner < 0 or owner >= len(models):
		helpers.log('Error: Owner id is out of range')
		return
	$roman_spear.queue_free()
	var model_instance = models[owner].instance()
	# set scale on first child of node
	model_instance.set_scale(MODEL_SCALE)
	model_instance.connect('clicked', self, 'unit_clicked')
	add_child(model_instance)

func unit_clicked():
	if $MouseClick.playing == true:
		$MouseClick.stop()
	$MouseClick.play()
	if highlight == false:
		highlight_on()
		emit_signal('unit_clicked')
	else:
		highlight_off()
	highlight = !highlight

func highlight_on() -> void:
	$Circle.show()
	$Highlight.play('HighlightRotate')

func highlight_off() -> void:
	$Circle.hide()
	$Highlight.stop()

func set_leader_status(status: bool):
	if status == true:
		$eagle.show()
	else:
		$eagle.hide()
