extends Spatial

const SCROLL_SPEED = 0.6

# min zoom is closest to the map
const MIN_ZOOM = 1.0
const MAX_ZOOM = 10.0
# how much we change the zoom_level on every wheel turn
const ZOOM_FACTOR = 0.3
# Duration of the zoom's tween animation.
const ZOOM_DURATION = 0.2
const MAP_PIXEL_SIZE = Vector2(6000.0, 4000.0)
# amount to slow down mouse panning by
const PAN_SCALING = 10.0
# amount to slow down the scale of panning the map during a zoom
const MOUSE_ZOOM_SCALING = 500.0

onready var zoom_tween: Tween = $Tweens/ZoomTween
onready var camera_tween: Tween = $Tweens/CameraTween
onready var camera = $Camera

# size of area can view on different zooms
# vec3 as x, y_top, y_bottom
const VIEW_AREA_ZOOM_MIN = Vector3(12.75, 9.0, -6.5)
const VIEW_AREA_ZOOM_MAX = Vector3(6.0, 5.2, -7.2)
# and then recalculated per zoom level
var view_area = Vector3(7.0, 4.0, -4.0)

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
	data.load_all_data()
	# load the region texture
	var image = load('res://gfx/map/map_regions_uncompressed.png')
	region_map = image.get_data()
	region_map.lock()
	helpers.log('Loaded region map')
	dragging = false
	add_cities()
	calculate_view_area()
	calculate_intersections()
	# do the initial setup, this should happen every change in the future
	$map_board.set_region_owners(data.get_region_owners_texture())

func _process(delta):
	calculate_intersections()
	set_map_color()
	if check_mouse_drag() == false:
		check_cursor_keys(delta)

func set_map_color():
	# just set mouse
	$map_board.set_mouse(map_intersect / MAP_PIXEL_SIZE)
	# in x range?
	if map_intersect.x >= 0.0 and map_intersect.x < MAP_PIXEL_SIZE.x:
		# in y range?
		if map_intersect.y >= 0.0 and map_intersect.y < MAP_PIXEL_SIZE.y:
			# yes, we need to set a color
			var col = region_map.get_pixel(map_intersect.x, map_intersect.y)
			$map_board.set_region_color(Vector3(col.r, col.g, col.b))
			return
	# set color to white
	$map_board.set_region_color(Vector3(1.0, 1.0, 1.0))

func _unhandled_input(event):
	if event.is_action_pressed('zoom_in'):
		# true: zoom in
		set_zoom_level(zoom_level - ZOOM_FACTOR, true)
	if event.is_action_pressed("zoom_out"):
		set_zoom_level(zoom_level + ZOOM_FACTOR, false)

func add_cities():
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
			drag_offset = get_mouse_map_coords(false)
			return true
	else:
		# we are dragging, or at least should be
		if Input.is_action_pressed(('middle_mouse')):
			# yes, move by delta of mouse move
			# false means to return by x/z, not by map pixels
			var current_move = get_mouse_map_coords(false)
			var drag_move = (drag_offset - current_move) / PAN_SCALING			
			camera.translation = check_panning_limits(Vector3(drag_move.x, 0.0, drag_move.y))
			return true
		else:
			dragging = false
	return false

func set_zoom_level(value, zoom_in):
	# We limit the value between min_zoom and max_zoom
	zoom_level = clamp(value, MIN_ZOOM, MAX_ZOOM)
	# at maximum zoom out, our camera.x angle should -90, at max zoom in, -55
	var zoom_c = 0.0
	zoom_c = zoom_level - MIN_ZOOM
	if zoom_c != 0.0:
		zoom_c = zoom_c / (MAX_ZOOM - MIN_ZOOM)
	# from 55 to 90 is 35
	var angle_delta = 35.0 * zoom_c
	var final_angle = -55.0 - angle_delta
	calculate_view_area()
	camera_tween.interpolate_property(
		$Camera, 'rotation_degrees:x', $Camera.rotation_degrees.x,
		final_angle, ZOOM_DURATION, Tween.TRANS_SINE, Tween.EASE_OUT)
	camera_tween.start()
	# if we zoom and are off-centre with the mouse, we must also move that way
	# cuurently we have the details per pixel, so apply scaling
	var delta = (map_intersect - camera_intersect) / MOUSE_ZOOM_SCALING
	# confirm the final destination
	if zoom_in == false:
		delta *= -1.0
	var final_move = check_panning_limits(Vector3(delta.x, 0.0, delta.y))
	# add the zoom
	final_move.y = zoom_level
	#  tween between camera zoom current value to the target zoom
	zoom_tween.interpolate_property(
		$Camera, 'translation', $Camera.translation, final_move,
		ZOOM_DURATION, Tween.TRANS_SINE, Tween.EASE_OUT)
	zoom_tween.start()
	
func scale_plane_coords(x, y):
	return Vector2(round((x + 12.5) * (MAP_PIXEL_SIZE.x / 25.0)),
				   round((y + 8.34) * (MAP_PIXEL_SIZE.y / 16.68)))

func get_mouse_map_coords(scaled: bool):
	# calculate what map pixel we are looking at
	# start by creating a horizontal plane where the map is
	var map_plane = Plane(Vector3(0, 1, 0), 0)
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
	# null if they don't intersect, otherwise gives the meeting point
	# Should be like (4.884333, 0, -4.067944), treat as {x:4.88, y:-4.07}
	var intersect = map_plane.intersects_ray(from, to)
	# convert to pixel map coords
	if scaled == true:
		return scale_plane_coords(intersect.x, intersect.z)
	return Vector2(intersect.x, intersect.z)

func calculate_intersections():
	map_intersect = get_mouse_map_coords(true)
	# do the camera aim manually
	var zpos = camera.translation.y * tan(deg2rad(90.0 + camera.rotation_degrees.x))
	# camera zpos is high when camera is looking at bottom, so offset is taken away (offset is _+ve)	
	camera_intersect = scale_plane_coords(camera.translation.x, camera.translation.z - zpos)

func check_panning_limits(move: Vector3):
	# only need to look at x and z
	move += camera.translation
	move.x = min(max(move.x, -view_area.x), view_area.x)
	move.z = min(max(move.z, view_area.z), view_area.y)
	return move

func check_cursor_keys(delta):
	var move = Vector3(0.0, 0.0, 0.0)
	var scaling = (zoom_level / SCROLL_SPEED) * delta
	if Input.is_action_pressed('left'):
		move.x -= scaling
	if Input.is_action_pressed('right'):
		move.x += scaling
	if Input.is_action_pressed('up'):
		move.z -= scaling
	if Input.is_action_pressed('down'):
		move.z += scaling
	if move != Vector3(0.0, 0.0, 0.0):
		camera.translation = check_panning_limits(move)

func calculate_view_area():
	var zoom = camera.translation.y
	# at zoom_min we should have VIEW_AREA_ZOOM_MIN
	# at zoom_max we should have VIEW_AREA_ZOOM_MAX
	var diff = (VIEW_AREA_ZOOM_MAX - VIEW_AREA_ZOOM_MIN) / (MAX_ZOOM - 1)
	view_area = ((zoom - MIN_ZOOM) * diff) + VIEW_AREA_ZOOM_MIN
