extends Spatial

const SCROLL_SPEED = 0.6

const MIN_ZOOM = 1.0
const MAX_ZOOM = 10.0
# how much we change the zoom_level on every wheel turn
const ZOOM_FACTOR = 0.5
# Duration of the zoom's tween animation.
const ZOOM_DURATION = 0.2

onready var zoom_tween: Tween = $Tweens/ZoomTween
onready var camera_tween: Tween = $Tweens/CameraTween
onready var camera = $Camera

var city_scene = preload('res://scenes/city/City.tscn')

var zoom_level = 3.5
var zoom_goal: float = 1.0

var map_intersect = null
var camera_intersect = null
var region_map: Image
var region_material: Material
var dragging: bool
var drag_offset: Vector2

func _ready():
	# setup all data
	data.loadAllData()
	# load the region texture
	var image = load('res://gfx/map/map_regions.png')
	region_map = image.get_data()
	region_map.lock()
	helpers.log('Loaded region map')
	dragging = false
	region_material = $GameMap.get_map_material()
	addCities()
	set_zoom_level(zoom_level)

func _process(delta):
	calculate_intersections()
	if check_mouse_drag() == false:
		check_cursor_keys(delta)

func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		set_zoom_level(zoom_level - ZOOM_FACTOR)
	if event.is_action_pressed("zoom_out"):
		set_zoom_level(zoom_level + ZOOM_FACTOR)

func addCities():
	for i in data.cities:
		var city_instance = city_scene.instance()
		city_instance.translation.x = i[0]
		city_instance.translation.z = i[1]
		city_instance.rotation_degrees.y = i[2]
		$Cities.add_child(city_instance)

func check_mouse_drag() -> bool:
	# return false if the mouse is doing nothing
	# check depending on current state
	if dragging == false:
		# middle mouse down?
		if Input.is_action_pressed('middle_mouse'):
			dragging = true
			# nothing to do this frame
			# we don't need the mouse position, we need where the mouse IS relative to the ground plane
			drag_offset = get_viewport().get_mouse_position()
			return true
	else:
		if Input.is_action_pressed(('middle_mouse')):
			# yes, move by delta of mouse move
			var current_move = get_viewport().get_mouse_position()
			var camera_offset = Vector2(camera.translation.x, camera.translation.z)
			camera_offset += (drag_offset - current_move) * zoom_level
			print(camera_offset)
			camera.translation.x = camera_offset.x
			camera.translation.z = camera_offset.y
			drag_offset = current_move
			return true
		else:
			dragging = false
	return false

func set_zoom_level(value):
	# We limit the value between min_zoom and max_zoom
	
	# print where from and where to
	#print(camera_intersect, ' -> ', map_intersect)
	
	zoom_level = clamp(value, MIN_ZOOM, MAX_ZOOM)
	#  tween between camera zoom current value to the target zoom
	zoom_tween.interpolate_property(
		$Camera,
		"translation:y",
		$Camera.translation.y,
		zoom_level,
		ZOOM_DURATION,
		Tween.TRANS_SINE,
		# Easing out: start fast and slow down as we reach the target value.
		Tween.EASE_OUT
	)
	zoom_tween.start()
	# at maximum zoom out, our camera.x angle should -90, at max zoom in, -55
	var zoom_c = 0.0
	# zero at MIN_ZOOM and 1 at MAX_ZOOM
	# zoom_level is between MIN_ZOOM and MAX_ZOOM
	# zoom_level - MIN_ZOOM
	# level is now 0 -> MAX_ZOOM... i.e. 0 to 4
	# (MAX_ZOOM - MIN_ZOOM) gets you the divisor 4, so
	zoom_c = zoom_level - MIN_ZOOM
	if zoom_c != 0.0:
		zoom_c = zoom_c / (MAX_ZOOM - MIN_ZOOM)
	# from 55 to 90 is 35
	var angle_delta = 35.0 * zoom_c
	var final_angle = -55.0 - angle_delta
	
	camera_tween.interpolate_property(
		$Camera,
		"rotation_degrees:x",
		$Camera.rotation_degrees.x,
		final_angle,
		ZOOM_DURATION,
		Tween.TRANS_SINE,
		# Easing out: start fast and slow down as we reach the target value.
		Tween.EASE_OUT
	)
	camera_tween.start()	
	# TODO: if we zoom and are off-centre with the mouse, we must also move that way
	
func calculate_intersections():
	# create a horizontal plane where the map is
	var map_plane = Plane(Vector3(0, 1, 0), 0)
	var mouse_pos = get_viewport().get_mouse_position()
	# Create the start and end points. Start is where the camera is
	var from = camera.project_ray_origin(mouse_pos)
	# and then extend it along by a long way
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
	# null if they don't intersect, otherwise gives the meeting point
	# Should be like (4.884333, 0, -4.067944), treat as {x:4.88, y:-4.07}
	map_intersect = map_plane.intersects_ray(from, to)
	
	# do the camera aim manually
	var zpos = camera.translation.y * tan(90.0 + camera.rotation.x)
	camera_intersect = Vector2(camera.translation.x, zpos)

func check_cursor_keys(delta):
	var move = Vector3(0.0, 0.0, 0.0)
	var scaling = (zoom_level / SCROLL_SPEED) * delta
	if Input.is_action_pressed("left"):
		move.x -= scaling
	if Input.is_action_pressed("right"):
		move.x += scaling
	if Input.is_action_pressed("up"):
		move.z -= scaling
	if Input.is_action_pressed("down"):
		move.z += scaling
	if move != Vector3(0.0, 0.0, 0.0):
		$Camera.translation += move
