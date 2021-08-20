extends Node2D

const MAP_CURSOR_SPEED: int = 800
const MAP_SIZE: Vector2 = Vector2(6000, 4000)

var regions: Array
var region_map: Image
var dragging: bool
var drag_offset: Vector2
var region_material: Material

func _ready():
	self.regions = constructors.getRegions()
	# load the region texture
	var image = load('res://gfx/map/map_regions.png')
	region_map = image.get_data()
	region_map.lock()
	helpers.log('Loaded region map')
	dragging = false
	region_material = $Map.get_material();

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
	# check depending on current state
	if dragging == false:
		# middle mouse down?
		if Input.is_action_pressed('middle_mouse'):
			dragging = true
			# nothing to do this frame
			drag_offset = get_viewport().get_mouse_position()
			return true
	else:
		if Input.is_action_pressed(('middle_mouse')):
			# yes, move by delta of mouse move
			var current_move = get_viewport().get_mouse_position()
			var camera_offset = $Camera2D.position + (drag_offset - current_move)
			drag_offset = current_move
			$Camera2D.position = fixOffset(camera_offset)
			return true
		else:
			dragging = false
	return false

func getCurrentRegion():
	var mouse_pos = get_global_mouse_position()
	# get the colour under this pixel from the region
	var color = region_map.get_pixel(mouse_pos.x, mouse_pos.y)
	# use this to update the shader
	region_material.set_shader_param('region_color', color);
	print(color)

func checkMapMoves(delta) -> void:
	if checkMouseDrag() == false:
		checkCursorKeys(delta)
	getCurrentRegion()

func _process(delta):
	checkMapMoves(delta)
