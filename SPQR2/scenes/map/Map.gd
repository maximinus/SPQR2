extends Node2D

const MAP_CURSOR_SPEED: int = 800
const MAP_SIZE: Vector2 = Vector2(4104, 2828)

var regions: Array

func _ready():
	self.regions = constructors.getRegions()

func fixOffset(camera_offset: Vector2) -> Vector2:
	# ensure the camera is not out-of-bounds
	# smallest values are half the size of the current window / screen
	var window_size: Vector2 = get_viewport().size / 2.0
	camera_offset.x = max(camera_offset.x, window_size.x)
	camera_offset.y = max(camera_offset.y, window_size.y)
	# the biggest it can be is the map size - half the window size
	var max_size: Vector2 = MAP_SIZE - window_size
	camera_offset.x = min(camera_offset.x, max_size.x)
	camera_offset.y = min(camera_offset.y, max_size.y)
	return camera_offset

func checkCursorKeys(delta) -> void:
	var direction: Vector2 = Vector2(0, 0)
	if Input.is_action_pressed('ui_up'):
		direction.y -= MAP_CURSOR_SPEED
	if Input.is_action_pressed('ui_down'):
		direction.y += MAP_CURSOR_SPEED
	if Input.is_action_pressed('ui_left'):
		direction.x -= MAP_CURSOR_SPEED
	if Input.is_action_pressed('ui_right'):
		direction.x += MAP_CURSOR_SPEED
	direction *= delta
	var camera_offset = $Camera2D.position + direction
	$Camera2D.position = fixOffset(camera_offset)

func checkMouseDrag() -> bool:
	# return false if the mouse is doing nothing
	return false

func checkMapMoves(delta) -> void:
	if checkMouseDrag() == false:
		checkCursorKeys(delta)

func _process(delta):
	checkMapMoves(delta)
