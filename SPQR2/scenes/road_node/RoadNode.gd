extends Spatial

const CITY_SIZE = 0.113
const NORMAL_SIZE = 0.07

var move_scene = preload('res://scenes/road_node/MoveDisplay.tscn')
var move_node = null

var id: int = -1
# this is an array if [TextureImage, id_of_road]
var road_data: Array = []

func _ready():
	pass

func setup(rnode: data.RNode) -> void:
	id = rnode.id
	set_display(rnode)
	road_data = data.get_connected_road_images(id)

func show_city():
	$city.show()

func hide_city():
	$city.hide()

func set_display(data: data.RNode) -> void:
	if data.population < 3.0:
		hide_city()
		$counter.mesh.top_radius = NORMAL_SIZE
		$counter.mesh.bottom_radius = NORMAL_SIZE
	else:
		show_city()
		$counter.mesh.top_radius = CITY_SIZE
		$counter.mesh.bottom_radius = CITY_SIZE

func show_move_highlight() -> void:
	$counter.hide()
	$move.show()

func hide_move_highlight() -> void:
	$counter.show()
	$move.hide()
	# if we have moves, delete them
	if move_node != null:
		move_node.queue_free()

func show_moves():
	# show the moves we can take
	var new_scene = move_scene.instance()
	new_scene.setup(road_data, data.rnodes[id].position)
	move_node = new_scene
	add_child(new_scene)
