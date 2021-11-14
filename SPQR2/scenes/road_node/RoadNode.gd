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
		$counter.mesh.top_radius = NORMAL_SIZE
		$counter.mesh.bottom_radius = NORMAL_SIZE
	else:
		show_city()
		$counter.mesh.top_radius = CITY_SIZE
		$counter.mesh.bottom_radius = CITY_SIZE

func show_move_highlight() -> void:
	$counter.hide()
	$move_display.show()

func hide_move_highlight() -> void:
	$counter.show()
	$move_display.hide()
