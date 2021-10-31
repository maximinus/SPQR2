extends Spatial

const SCROLL_SPEED = 0.6

# min zoom is closest to the map
const MIN_ZOOM = 1.0
const MAX_ZOOM = 10.0
# how much we change the zoom_level on every wheel turn
const ZOOM_FACTOR = 0.3
# Duration of the zoom's tween animation.
const ZOOM_DURATION = 0.2
# amount to slow down mouse panning by
const PAN_SCALING = 10.0
# amount to slow down the scale of panning the map during a zoom
const MOUSE_ZOOM_SCALING = 500.0
const WINDOW_MIN_SIZE = Vector2(800, 600)

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
var unit_scene = preload("res://scenes/unit/Unit.tscn")

var zoom_level = 3.5
var zoom_goal: float = 1.0

var map_intersect = null
var camera_intersect = null
var region_map: Image
var region_material: Material
var dragging: bool
var drag_offset: Vector2

func _ready():
	# ensure window size has a minimum
	OS.min_window_size = WINDOW_MIN_SIZE
	# setup all data
	data.load_all_data()
	# load the region texture
	var image = load('res://gfx/map/map_regions_uncompressed.png')
	region_map = image.get_data()
	region_map.lock()
	helpers.log('Loaded region map')
	dragging = false
	add_cities()
	add_armies()
	calculate_view_area()
	calculate_intersections()
	# do the initial setup, this should happen every change in the future
	$map_board.set_region_owners(data.get_region_owners_texture())
	# roads are done by this point, so set those up as well
	$map_board.set_road_texture(data.road_texture)
	# display correct money values
	$CanvasLayer/Overlay.set_gold_silver(data.get_player_gold(), data.get_player_silver())
	# force a click on the Rome region to force update
	check_region_click(cn.ROME_PROVINCE_COORDS)

func _process(delta):
	# what are the mouse and camera looking at?
	calculate_intersections()
	update_minimap_pin()
	check_ui_actions()
	# what color are we over for the shader?
	set_map_color()
	# move the map
	if check_mouse_drag() == false:
		check_cursor_keys(delta)

func check_ui_actions() -> void:
	# check non-map ui actions
	if Input.is_action_just_pressed('menu'):
		$CanvasLayer/PauseMenu.display()
		get_tree().paused = true
	if Input.is_action_just_pressed('test_event'):
		helpers.log('Testing events')
		$CanvasLayer/Event.ask('Congress wishes to end conflict with Eygpt',
			['Refuse the request', 'Withdraw forces', 'Ignore the request'])

func set_map_color() -> void:
	# pass mouse position to shader
	$map_board.set_mouse(map_intersect / cn.MAP_PIXEL_SIZE)
	# now test against the pixel map. In range?
	if map_intersect.x >= 0.0 and map_intersect.x < cn.MAP_PIXEL_SIZE.x:
		if map_intersect.y >= 0.0 and map_intersect.y < cn.MAP_PIXEL_SIZE.y:
			# yes, we need to set a color
			var col = region_map.get_pixel(map_intersect.x, map_intersect.y)
			$map_board.set_region_color(Vector3(col.r, col.g, col.b))
			return
	# set color to white, i.e. tell the shader there is no region
	$map_board.set_region_color(Vector3(1.0, 1.0, 1.0))

func _input(event) -> void:
	if event.is_action_pressed('zoom_in'):
		# true: zoom in
		set_zoom_level(zoom_level - ZOOM_FACTOR)
	if event.is_action_pressed("zoom_out"):
		set_zoom_level(zoom_level + ZOOM_FACTOR)
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			check_region_click(null)

func check_region_click(coords) -> void:
	# update details if a region is clicked
	# convert the mouse pos to real co-ords
	if coords == null:
		coords = get_mouse_map_coords(true)
	if coords.x < 0 or coords.y < 0:
		# out of bounds, do nothing
		return
	if coords.x < cn.MAP_PIXEL_SIZE.x and coords.y < cn.MAP_PIXEL_SIZE.y:
		# was really clicked, get the region color
		var col = region_map.get_pixel(coords.x, coords.y)
		# if the alpha is zero you clicked in a place with no region
		if col.a == 0.0:
			return
		# calculate the index
		var index = helpers.get_index_from_region_color(col)
		# check range to be sure
		if index >= 0 and index < len(data.regions):
			# get the city details
			$CanvasLayer/Overlay.update_region_info(data.regions[index])

func add_cities() -> void:
	# add cities to scene from world data
	for i in data.regions:
		if i.city != null:
			var city_instance = city_scene.instance()
			var city_pos = i.city.city_pos
			city_instance.translation.x = city_pos[0]
			city_instance.translation.z = city_pos[1]
			city_instance.rotation_degrees.y = city_pos[2]
			$Cities.add_child(city_instance)

func add_armies() -> void:
	for i in data.armies:
		var unit_instance = unit_scene.instance()
		unit_instance.set_unit_type(data.get_unit_owner(i.id))
		var unit_pos = i.get_map_position()
		unit_instance.translation.x = unit_pos[0]
		unit_instance.translation.z = unit_pos[1]
		if data.leader_unit == i.id:
			unit_instance.set_leader_status(true)
		$Soldiers.add_child(unit_instance)

func check_mouse_drag() -> bool:
	# return false if the mouse is doing nothing
	# check depending on current state
	if dragging == false:
		# middle mouse down?
		if Input.is_action_pressed('middle_mouse'):
			dragging = true
			$CanvasLayer/Overlay.set_default_cursor_shape(Input.CURSOR_DRAG)
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
			$CanvasLayer/Overlay.set_default_cursor_shape(Input.CURSOR_ARROW)
	return false

func set_zoom_level(value) -> void:
	# zoom the camera with a tween. May also need to tween the x/z position
	# We limit the value between min_zoom and max_zoom
	# don't update if the zoom level doesn't change
	var new_zoom_level = clamp(value, MIN_ZOOM, MAX_ZOOM)
	if new_zoom_level == zoom_level:
		return
	zoom_level = new_zoom_level
	# at maximum zoom out, our camera.x angle should -90, at max zoom in, -55
	var zoom_c = 0.0
	zoom_c = zoom_level - MIN_ZOOM
	if zoom_c != 0.0:
		zoom_c = zoom_c / (MAX_ZOOM - MIN_ZOOM)
	# from 55 to 90 is 35
	var angle_delta = 35.0 * zoom_c
	var final_angle = -55.0 - angle_delta
	# update what we can see
	calculate_view_area()
	camera_tween.interpolate_property(
		$Camera, 'rotation_degrees:x', $Camera.rotation_degrees.x,
		final_angle, ZOOM_DURATION, Tween.TRANS_SINE, Tween.EASE_OUT)
	camera_tween.start()
	# if we zoom and are off-centre with the mouse, we must also move that way
	# cuurently we have the details per pixel, so apply scaling
	var delta = (map_intersect - camera_intersect) / MOUSE_ZOOM_SCALING
	# confirm the final destination
	var final_move = check_panning_limits(Vector3(delta.x, 0.0, delta.y))
	# add the zoom
	final_move.y = zoom_level
	# tween the camera to final_move
	zoom_tween.interpolate_property(
		$Camera, 'translation', $Camera.translation, final_move,
		ZOOM_DURATION, Tween.TRANS_SINE, Tween.EASE_OUT)
	zoom_tween.start()
	
func scale_plane_coords(x, y) -> Vector2:
	# given plane coords, return pixel coords
	# plane of (-12.5, -8.34) is (0,0) in pixels
	# Since map is (12.5, 8.34) * 2 = (25.0, 16.68) in size,
	# divide the pixel size by those values
	return Vector2(round((x + 12.5) * (cn.MAP_PIXEL_SIZE.x / 25.0)),
				   round((y + 8.34) * (cn.MAP_PIXEL_SIZE.y / 16.68)))

func get_mouse_map_coords(scaled: bool) -> Vector2:
	# calculate what map pixel the mouse is looking at
	# start by creating a horizontal plane where the map is
	var map_plane = Plane(Vector3(0, 1, 0), 0)
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
	# null if they don't intersect, otherwise gives the meeting point
	# Should be like (4.884333, 0, -4.067944), treat as {x:4.88, y:-4.07}
	var intersect = map_plane.intersects_ray(from, to)
	# convert to pixel map coords if needed
	if scaled == true:
		return scale_plane_coords(intersect.x, intersect.z)
	return Vector2(intersect.x, intersect.z)

func calculate_intersections() -> void:
	# calculate what the camera and mouse pointer are looking at
	map_intersect = get_mouse_map_coords(true)
	# do the camera aim manually
	var zpos = camera.translation.y * tan(deg2rad(90.0 + camera.rotation_degrees.x))
	# camera zpos is high when camera is looking at bottom, so offset is taken away (offset is _+ve)	
	camera_intersect = scale_plane_coords(camera.translation.x, camera.translation.z - zpos)

func check_panning_limits(move: Vector3) -> Vector3:
	# restrict the given move to the view area
	# return the final camera position
	# only need to look at x and z
	move += camera.translation
	# limit from -view_area to +view_area
	move.x = min(max(move.x, -view_area.x), view_area.x)
	move.z = min(max(move.z, view_area.z), view_area.y)
	return move

func check_cursor_keys(delta) -> void:
	# if cursor keys are down, scroll the map
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

func calculate_view_area() -> void:
	# calculate the area which can be viewed, based on the current zoom
	var zoom = camera.translation.y
	# at zoom_min we should have VIEW_AREA_ZOOM_MIN
	# at zoom_max we should have VIEW_AREA_ZOOM_MAX
	var diff = (VIEW_AREA_ZOOM_MAX - VIEW_AREA_ZOOM_MIN) / (MAX_ZOOM - 1)
	view_area = ((zoom - MIN_ZOOM) * diff) + VIEW_AREA_ZOOM_MIN

func _on_Overlay_mini_map(pos) -> void:
	# the mini-map has been clicked. The co-ords are the UV of the map,
	# i.e. 0 to 1 on both the axis. Update the map and the map pin
	var half_map = cn.MAP_REAL_SIZE / 2.0
	pos *= cn.MAP_REAL_SIZE
	pos -= half_map
	# the "move" would be where we are, compared to where we want to be
	# the camera intersect is in pixels, so recalculate
	var camera_pos = (camera_intersect / cn.MAP_PIXEL_SIZE) * cn.MAP_REAL_SIZE
	camera_pos -= half_map
	pos -= camera_pos
	var new_pos = check_panning_limits(Vector3(pos.x, 0.0, pos.y))
	# no need to tween, but if a camera tween exists, stop it
	camera_tween.stop_all()
	camera.translation = new_pos	
	# finally, we need update the pin position (since panning limits may have restricted it)
	calculate_intersections()
	update_minimap_pin()

func update_minimap_pin() -> void:
	# update where the pin is on the mini-map
	var pin_pos = (camera_intersect / cn.MAP_PIXEL_SIZE)
	$CanvasLayer/Overlay.update_map_pin(pin_pos)

func _on_Overlay_change_view(index) -> void:
	# update the shader graphics to change the view
	if index == cn.RegionDisplay.OWNERS:
		$map_board.set_region_owners(data.get_region_owners_texture())
	elif index == cn.RegionDisplay.ARMY:
		$map_board.set_region_owners(data.get_army_stats_texture())
	elif index == cn.RegionDisplay.MONEY:
		$map_board.set_region_owners(data.get_money_stats_texture())
	else:
		helpers.log('Caught incorrect overlay change: ' + str(index))

func _on_Event_answer_given(answer: int):
	# we raised an event, now we have the answer
	# since the screen was frozen, nothing else happened	
	helpers.log('Got answer to an event: ' + str(answer))
