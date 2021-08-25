extends Node2D

const MAP_CURSOR_SPEED: int = 800
const MAP_SIZE: Vector2 = Vector2(6000, 4000)
const OVERLAY_WIDTH = 320
const ZOOM_SMOOTHING = 12.0

var region_map: Image
var dragging: bool
var drag_offset: Vector2
var region_material: Material
var city_scene = preload('res://scenes/city/City.tscn')

# needed for zooming
var zoom_min: float = 0.2
var zoom_max: float = 2.0
var zoom_speed: float = 0.12
var zoom_goal: float = 1.0


func _ready():
	# setup all data
	data.loadAllData()
	# load the region texture
	var image = load('res://gfx/map/map_regions.png')
	region_map = image.get_data()
	region_map.lock()
	helpers.log('Loaded region map')
	dragging = false
	region_material = $Map.get_material()
	addCities()

func addCities():
	for i in data.cities:
		var city_instance = city_scene.instance()
		city_instance.position.x = i[0]
		city_instance.position.y = i[1]
		$Cities.add_child(city_instance)

func fixOffset(camera_offset: Vector2) -> Vector2:
	# ensure the camera is not out-of-bounds
	# smallest values are half the size of the current window / screen
	var window_size: Vector2 = get_viewport().size / 2.0
	camera_offset.x = max(camera_offset.x, window_size.x)
	camera_offset.y = max(camera_offset.y, window_size.y)
	# the biggest it can be is the map size - half the window size
	var max_size: Vector2 = MAP_SIZE - window_size
	camera_offset.x = min(camera_offset.x, max_size.x + OVERLAY_WIDTH)
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
	direction *= delta * zoom_goal
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
			var camera_offset = $Camera2D.position + (drag_offset - current_move) * zoom_goal
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

func checkMapMoves(delta) -> void:
	if checkMouseDrag() == false:
		checkCursorKeys(delta)
	getCurrentRegion()

func _process(delta):
	checkMapMoves(delta)
	var lerp_value = min(ZOOM_SMOOTHING * delta, 1.0)
	var zoom = lerp($Camera2D.zoom.x, zoom_goal, lerp_value)
	$Camera2D.zoom = Vector2(zoom, zoom)

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	# was this a click?
	var mouse_pos = get_global_mouse_position()
	if (event is InputEventMouseButton and event.pressed):
		var color = region_map.get_pixel(mouse_pos.x, mouse_pos.y)
		var g = int(color.g * 256.0)
		var b = int(color.b * 256.0)
		var clicked_region = MapRegion.getMatch(g, b)
		if clicked_region == null:
			# no match, no region
			return
		# we have a match
		$CanvasLayer/Overlay.updateRegionInfo(clicked_region)

func _input(event):
	if not event is InputEventMouseButton:
		return
	if not event.is_pressed():
		return
	if event.button_index == BUTTON_WHEEL_UP:
		if zoom_goal > zoom_min:
			zoom_goal = max(zoom_goal - zoom_speed, zoom_min)
	if event.button_index == BUTTON_WHEEL_DOWN:
		if zoom_goal < zoom_max:
			zoom_goal = min(zoom_goal + zoom_speed, zoom_max)
	print(zoom_goal)
