extends Spatial

# Node to display a unit model on screen

const MODEL_SCALE = Vector3(0.07, 0.07, 0.07)
# world position change per second
const UNIT_MOVE_SPEED = 0.8

signal unit_clicked
signal unit_unclicked
signal check_shared_regions

var move_scene = preload('res://scenes/move_display/MoveDisplay.tscn')
var move_node = null

# preload the models
var models = [preload('res://scenes/units/roman_spear.tscn'),
			  preload('res://scenes/units/celtic_spearman.tscn')]
var highlight = false
var unit_display: int = -1
var road_data: Array = []
var unit_data
var moving: bool = false

func _ready():
	pass

func setup(display: int, unit) -> void:
	if display < 0 or display >= len(models):
		helpers.log('Error: Owner id is out of range')
		return
	unit_display = display
	unit_data = unit
	road_data = data.get_road_arrows_from_node_id(unit_data.location.id)
	$roman_spear.queue_free()
	var model_instance = models[display].instance()
	model_instance.set_scale(MODEL_SCALE)
	model_instance.connect('clicked', self, 'unit_clicked')
	add_child(model_instance)

func unit_clicked():
	# ignore clicks if animations are blocked
	if data.animation_blocked == true:
		return
	# ignore clicks if unit is not Roman
	if unit_data.is_roman() == false:
		return
	if highlight == false:
		highlight_on()
		emit_signal('unit_clicked', self)
	else:
		highlight_off()
		emit_signal('unit_unclicked', self)

func check_click() -> bool:
	if move_node == null:
		helpers.log('Error: Click check with no move node')
		return false
	var move_data = move_node.check_click()
	if len(move_data) != 0:
		# can we actually move there?
		if move_data[0] < 0:
			# no, blocked - deselect all for now
			hide_moves()
			highlight_off()
			play_click()
			return true
		hide_moves()
		highlight_off()
		play_click()
		# is it a battle?
		if move_data[2] == true:
			print('Starting battle move')
			start_move(move_data, true)
		else:
			start_move(move_data, false)
		return true
	return false

func adjust_points_for_battle_move(path_points: Array, end_position: Vector2) -> Array:
	# now we have all the points, we will adjust. Go through backwards until
	# we find a point NOT inside the destination unit radius
	# loop over points backwards
	var new_line_points: Array = []
	for i in range(len(path_points) - 2, 1, -1):
		# is this point inside the radius?
		var distance_to_node = path_points[i].distance_to(end_position)
		if path_points[i].distance_to(end_position) <= cn.UNIT_RADIUS_MAP_COORDS:
			# yes, continue on to the next one
			continue
		# we have found the first place that is outside the radius
		# we need to construct a line from this point to where we want to stop
		# i.e., given a line from this point to end_position
		var partial_distance: float = (distance_to_node - cn.UNIT_RADIUS_MAP_COORDS) / distance_to_node
		var move_delta: Vector2 = (end_position - path_points[i]) * partial_distance
	
		# these are the points we require, so now construct the fill array of points
		for j in range(len(path_points) - 1):
			new_line_points.append(path_points[j])
		new_line_points.append(path_points[i] + move_delta)
		break
	print(new_line_points)
	return new_line_points

func start_move(move_data: Array, is_battle: bool) -> void:
	# move data is [node_id, road_id]
	# start the process of moving from one node to the next
	# we need the paths of the roads. We have the TO, now get the FROM
	var path_points: Array = []
	var road_data = data.roads[move_data[1]]
	var start_node = unit_data.location.id
	var end_position: Vector2
	# work out where to go, points and final node
	if road_data.start_node != start_node:
		# must be end 
		if road_data.end_node != start_node:
			helpers.log('Error: Roads do not connect!')
			return
		path_points = road_data.points.duplicate()
		path_points.invert()
		end_position = data.rnodes[road_data.start_node].position
	else:
		path_points = road_data.points.duplicate()
		end_position = data.rnodes[road_data.end_node].position
		
	if is_battle == false:
		# move the unit to the node internally
		data.move_unit(unit_data.id, move_data[0])
		
	# now we have a list of points. Replace the starting point with our position
	path_points[0] = Vector2(translation.x, translation.z)
	# replace the end position with the position of the node we are going to
	path_points[-1] = end_position
	
	# all points except the start and the end must be converted to map coords
	for i in range(1, len(path_points) - 1):
		var vector_convert: Vector2 = Vector2(path_points[i][0], path_points[i][1])
		path_points[i] = helpers.pixel_to_map(vector_convert)
		
	if is_battle == true:
		path_points = adjust_points_for_battle_move(path_points, end_position)
		
	# now we build up the animations. Remove the old one if it exists
	$MoveUnit.remove_animation('move')
	$MoveUnit.remove_animation('rotate')
	var anim = Animation.new()
	var track_index = anim.add_track(Animation.TYPE_TRANSFORM)
	anim.track_set_path(track_index, @'.:transform/translation')
	var total_time: float = 0.0
	# stay where we are vertically
	var ypos = translation.y
	# start where we are
	anim.transform_track_insert_key(track_index, 0.0, translation,
			Quat(0.0, 0.0, 0.0, 1.0), Vector3(1.0, 1.0, 1.0))
			
	# set up rotation
	# Unit starts at angle_degres = 0, pointing towards you
	# So we need first calculate the angle from where we are now, to where we will be
	# This works for all nodes, except for the last we know the value will be 0 again
	# The unit rotates on the y axis
	# TODO: Why does this not work?
	var rotate_index = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(rotate_index, @'.:rotation_degrees:y')
	anim.track_insert_key(rotate_index, 0.0, rotation_degrees.y)
			
	for i in range(1, len(path_points)):
		var start: Vector2 = path_points[i - 1]
		var destination: Vector2 = path_points[i]
		var time = start.distance_to(destination) / UNIT_MOVE_SPEED
		total_time += time
		anim.transform_track_insert_key(track_index, total_time, Vector3(destination.x, ypos, destination.y),
			Quat(0.0, 0.0, 0.0, 1.0), Vector3(1.0, 1.0, 1.0))
			
		# now calculate rotation
		# the starting point is what we have now, the next we need calculate, unless this is the end
		var rotate_end: float = 0.0
		if i < len(path_points) - 1:
			# calculate. We have the 2 positions, start and destination
			rotate_end = rad2deg(start.angle_to_point(destination)) + 180.0
		# TODO: Fix the maths for this
		rotate_end = 0.0
		anim.track_insert_key(rotate_index, total_time, rotate_end)
			
	# now all the tracks have been added, set length of animation
	anim.length = total_time
	# add to animation player
	$MoveUnit.add_animation('move', anim)
	# finally, you can play the animation and audio
	data.animation_blocked = true
	$MoveUnit.play('move')
	$Marching.play()

func _on_MoveUnit_animation_finished(_anim_name):
	# this can only ever be the move animation
	$Marching.stop()
	$Stomping.play()
	# update the roads we can go to
	road_data = data.get_road_arrows_from_node_id(unit_data.location.id)
	data.animation_blocked = false
	# now we need to check to see if the shader needs updating
	emit_signal('check_shared_regions')

func play_click():
	if $MouseClick.playing == true:
		$MouseClick.stop()
	$MouseClick.play()

func highlight_on() -> void:
	if highlight == false:
		play_click()
		$Circle.show()
		$Highlight.play('HighlightRotate')
		show_moves()
		highlight = true

func highlight_off() -> void:
	if highlight == true:
		play_click()
		$Circle.hide()
		$Highlight.stop()
		hide_moves()
		highlight = false

func show_moves() -> void:
	# show the moves we can take
	var new_scene = move_scene.instance()
	new_scene.setup(road_data, unit_data.location)
	move_node = new_scene
	add_child(new_scene)

func hide_moves() -> void:
	if move_node == null:
		return
	move_node.queue_free()
	move_node = null

func set_leader_status(status: bool) -> void:
	if status == true:
		$eagle.show()
	else:
		$eagle.hide()
