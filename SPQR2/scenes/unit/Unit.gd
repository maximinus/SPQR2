extends Spatial

# Node to display a unit model on screen

const MODEL_SCALE = Vector3(0.07, 0.07, 0.07)
signal unit_clicked
signal unit_unclicked

var move_scene = preload('res://scenes/road_node/MoveDisplay.tscn')
var move_node = null

# preload the models
var models = [preload('res://scenes/units/roman_spear.tscn'),
			  preload('res://scenes/units/celtic_spearman.tscn')]
var highlight = false
var unit_display: int = -1
var road_data: Array = []
var unit_data

func _ready():
	pass

func setup(display: int, unit) -> void:
	if display < 0 or display >= len(models):
		helpers.log('Error: Owner id is out of range')
		return
	unit_display = display
	unit_data = unit
	road_data = data.get_road_arrows_from_node_id(unit_data.location.id)
	$roman_spear.queue_free()
	var model_instance = models[display].instance()
	model_instance.set_scale(MODEL_SCALE)
	model_instance.connect('clicked', self, 'unit_clicked')
	add_child(model_instance)

func unit_clicked():
	if $MouseClick.playing == true:
		$MouseClick.stop()
	$MouseClick.play()
	if highlight == false:
		highlight_on()
	else:
		highlight_off()
	highlight = !highlight
	

func highlight_on() -> void:
	$Circle.show()
	$Highlight.play('HighlightRotate')
	show_moves()
	emit_signal('unit_clicked', unit_data.id)

func highlight_off() -> void:
	$Circle.hide()
	$Highlight.stop()
	hide_moves()
	emit_signal('unit_unclicked', unit_data.id)

func show_moves():
	# show the moves we can take
	var new_scene = move_scene.instance()
	new_scene.setup(road_data, unit_data.location.position)
	move_node = new_scene
	add_child(new_scene)

func hide_moves():
	move_node.queue_free()

func set_leader_status(status: bool):
	if status == true:
		$eagle.show()
	else:
		$eagle.hide()
