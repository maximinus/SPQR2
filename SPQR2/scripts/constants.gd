extends Node

const MAP_PIXEL_SIZE: Vector2 = Vector2(6000.0, 4000.0)
const MAP_REAL_SIZE: Vector2 = Vector2(25.0, 16.68)
const ROME_PROVINCE_COORDS: Vector2 = Vector2(1800.0, 1600.0)
const MAP_TO_PIXEL_SCALE: float = 240.0

const UNIT_RADIUS_MAP_COORDS: float = 0.14

const ROME_DEFAULT_COLOR: Color = Color(0.91, 0.0664, 0.0664, 1.0)
const CELT_COLOR: Color = Color('246bce')

const ROAD_IMAGE_BORDER: Vector2 = Vector2(16.0, 16.0)

# sounds
const AUDIO_MIN_VOLUME = 0.0
const AUDIO_MAX_VOLUME = 100.0

# paths
const CONFIG_FILE = 'user://spqr.cfg'

class RoadMoveDisplay:
	# helper function to store details for displaying movements
	var image: ImageTexture
	var red_image: ImageTexture
	var move_to: int
	var pos: Vector2
	var points: Array
	
	func _init(img, red_img, road, to, pts):
		# arrow images
		image = img
		red_image = red_img
		# road is the id of the ROAD
		move_to = road
		# the position of the image
		pos = to
		# the points of the line
		points = pts

enum RegionDisplay {
	OWNERS,
	MONEY,
	ARMY
}
