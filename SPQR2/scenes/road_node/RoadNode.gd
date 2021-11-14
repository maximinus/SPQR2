extends Spatial

const CITY_SIZE = 0.113
const NORMAL_SIZE = 0.07

func _ready():
	pass

func show_city():
	$city.show()

func hide_city():
	$city.hide()

func set_display(data: data.RNode) -> void:
	if data.population < 3.0:
		hide_city()
		helpers.log('Small')
		$node.mesh.top_radius = NORMAL_SIZE
		$node.mesh.bottom_radius = NORMAL_SIZE
	else:
		show_city()
		$node.mesh.top_radius = CITY_SIZE
		$node.mesh.bottom_radius = CITY_SIZE
