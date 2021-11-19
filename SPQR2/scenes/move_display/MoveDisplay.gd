extends Spatial

const DISPLAY_HEIGHT = 0.01
const MARGIN_INCREASE = 1.2

var path_lookups: Array = []
var bound_point: Vector2 = Vector2(0.0, 0.0)
var bound_distance: float = 0.0
var last_chosen = null

func _ready():
	pass

func setup(image_data: Array, pos: Vector2) -> void:
	# add each image as a new mesh with a single texture
	# the array is an aray of cn.RoadMoveDisplay instances
	for i in image_data:
		# work out world size after scaling
		var mesh_size = Vector2(i.image.get_width() / cn.MAP_TO_PIXEL_SCALE,
								i.image.get_height() / cn.MAP_TO_PIXEL_SCALE)
		# create the new mesh
		var quad: PlaneMesh = PlaneMesh.new()
		quad.set_size(mesh_size)
		var mesh: CSGMesh = CSGMesh.new()
		mesh.set_mesh(quad)
		# add texture, make see-through
		var m_material = SpatialMaterial.new()
		m_material.set_feature(SpatialMaterial.FEATURE_TRANSPARENT, true)
		m_material.set_texture(SpatialMaterial.TEXTURE_ALBEDO, i.image)
		m_material.set_emission(Color(1.0, 1.0, 1.0, 1.0))
		m_material.set_feature(SpatialMaterial.FEATURE_EMISSION, false)
		mesh.set_material(m_material)
		# position is in pixels, translate and offset with node position
		var map_p = helpers.pixel_to_map(i.pos) - pos
		# we also need to offset the image by half it's size, otherwise it is drawn centered
		map_p += mesh_size / 2.0
		mesh.translation.y = DISPLAY_HEIGHT
		mesh.translation = Vector3(map_p.x, DISPLAY_HEIGHT, map_p.y)
		
		# convert the points to a Vector2 array
		var vec_points: Array = []
		for j in i.points:
			vec_points.append(Vector2(j[0], j[1]))
		
		path_lookups.append([vec_points, m_material, i.move_to])
		$Moves.add_child(mesh)
	# create an out-of-bounds circle
	create_bounding_circle()

func check_click() -> int:
	# return true if we moved
	var path_clicked = get_closest_line()
	if path_clicked == null:
		# nothing to do
		return -1
	return path_clicked[2]

func create_bounding_circle() -> void:
	# get the middle / average point
	var total: int = 0
	bound_point = Vector2(0.0, 0.0)
	for i in path_lookups:
		for j in i[0]:
			bound_point += j
			total += 1
	bound_point /= float(total)
	# now calculate the furthest distance from that point
	var furthest: float = 0.0
	for i in path_lookups:
		for j in i[0]:
			var distance: float  = bound_point.distance_to(j)
			if distance > furthest:
				furthest = distance
	# we can treat the distance as the furthest away to ignore the mouse
	# but we'll also increase the distance by a small margin
	bound_distance = furthest * MARGIN_INCREASE

func show_line_highlight(mat: SpatialMaterial) -> void:
	mat.set_feature(SpatialMaterial.FEATURE_EMISSION, true)

func hide_line_highlight(mat: SpatialMaterial) -> void:
	mat.set_feature(SpatialMaterial.FEATURE_EMISSION, false)

func _process(delta) -> void:
	check_closest_line()

func get_closest_line():
	var current_coords = data.get_mouse_coords()
	# are we outside the bounding range?
	if current_coords.distance_to(bound_point) > bound_distance:
		# just clear all highlights
		return null
	var closest: float = 10000.0
	var path_chosen = null
	for i in path_lookups:
		for point in i[0]:
			var distance = current_coords.distance_to(point)
			if distance < closest:
				closest = distance
				path_chosen = i
	return path_chosen

func check_closest_line() -> void:
	var result = get_closest_line()
	if result == null:
		# just clear all highlights
		for i in path_lookups:
			hide_line_highlight(i[1])
		last_chosen = null
		return
	for i in path_lookups:
		if i == result:
			show_line_highlight(i[1])
		else:
			hide_line_highlight(i[1])
	if last_chosen != result and last_chosen != null:
		play_rollover()
	last_chosen = result

func play_rollover() -> void:
	if $ArrowRollover.playing:
		$ArrowRollover.stop()
	$ArrowRollover.play()
