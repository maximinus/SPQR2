tool
extends Line2D

const NO_ROAD = Color(0.4, 0.2, 0.0, 1.0)
const BAD_ROAD = Color(0.7, 0.5, 0.1, 1.0)
const GOOD_ROAD = Color(1.0, 1.0, 1.0, 1.0)

export(float) var road_state = 1.0 setget set_road_state
export(int) var id = 0

func _ready():
	set_road_color()

func set_road_color():
	if road_state <= 1.0:
		default_color = NO_ROAD
	elif road_state <= 2.0:
		default_color = BAD_ROAD
	else:
		default_color = GOOD_ROAD

func set_road_state(new_state):
	road_state = new_state
	set_road_color()
